import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { Resend } from "resend";
import { SecretManagerServiceClient } from "@google-cloud/secret-manager";

admin.initializeApp();

const db = admin.firestore();
const secretClient = new SecretManagerServiceClient();

// 環境判定（ログ出力用）
const ENV = functions.config().env?.name || process.env.FUNCTIONS_ENV || "prod";

// PII マスキング関数
export function maskEmail(email: string): string {
  if (!email || !email.includes("@")) {
    return email; // Invalid email, return as-is
  }

  const [localPart, domain] = email.split("@");
  if (!localPart || localPart.length === 0) {
    return email; // No local part, return as-is
  }

  const maskedLocalPart = localPart[0] + "***";
  return `${maskedLocalPart}@${domain}`;
}

// Resend API Key キャッシュ（メモリ）
let cachedResendApiKey: string | null = null;

// Secret Manager から Resend API Key を取得（キャッシュ付き）
async function getResendApiKey(): Promise<string> {
  // キャッシュがあれば再利用
  if (cachedResendApiKey) {
    console.log("Using cached Resend API key");
    return cachedResendApiKey;
  }

  // 初回のみ Secret Manager から取得
  console.log("Fetching Resend API key from Secret Manager");
  const projectId = process.env.GCLOUD_PROJECT || process.env.GCP_PROJECT;
  const [version] = await secretClient.accessSecretVersion({
    name: `projects/${projectId}/secrets/resend-api-key/versions/latest`,
  });

  cachedResendApiKey = version.payload?.data?.toString() || "";
  return cachedResendApiKey;
}

/**
 * 毎日9:00 JST に実行される定期チェック
 * 48時間以上チェックインがないユーザーの緊急連絡先にメール送信
 */
export const checkInactiveUsers = functions.pubsub
  .schedule("0 9 * * *")
  .timeZone("Asia/Tokyo")
  .onRun(async () => {
    console.log(`Starting inactive users check... (ENV: ${ENV})`);

    // 48時間前のタイムスタンプ
    const threshold = new Date(Date.now() - 48 * 60 * 60 * 1000);

    try {
      // 未チェック AND 未通知のユーザーを取得
      const snapshot = await db
        .collection("users")
        .where("lastCheckIn", "<", threshold)
        .where("notified", "==", false)
        .get();

      console.log(`Found ${snapshot.size} inactive users`);

      for (const doc of snapshot.docs) {
        await processInactiveUser(doc.id, doc.data());
      }

      // Note: 失敗した通知は notified=false のまま残るため、
      // 次回スケジュール実行時に自動的に再試行される

      console.log("Inactive users check completed");
    } catch (error) {
      console.error("Error checking inactive users:", error);
      throw error;
    }
  });

/**
 * 未チェックユーザーの処理（トランザクションベース）
 */
async function processInactiveUser(
  deviceId: string,
  userData: FirebaseFirestore.DocumentData
): Promise<void> {
  const { name, emergencyContactEmail, emergencyContactName } = userData;

  // バリデーション
  if (!emergencyContactEmail || !emergencyContactEmail.includes("@")) {
    console.log(`Skipping ${deviceId}: invalid email`);
    await logNotification(deviceId, emergencyContactEmail || "", "skipped", 0);
    return;
  }

  const userRef = db.collection("users").doc(deviceId);

  try {
    // トランザクション: notified フラグを先に更新（重複送信防止）
    await db.runTransaction(async (transaction) => {
      const userDoc = await transaction.get(userRef);

      if (!userDoc.exists) {
        throw new Error("User document not found");
      }

      const currentData = userDoc.data();
      if (currentData?.notified === true) {
        // 既に通知済み（並行実行時の安全策）
        throw new Error("Already notified");
      }

      // 競合状態チェック: トランザクション内でlastCheckInを再確認
      const threshold = new Date(Date.now() - 48 * 60 * 60 * 1000);
      const lastCheckIn = currentData?.lastCheckIn?.toDate();

      if (!lastCheckIn || lastCheckIn >= threshold) {
        // クエリ後にチェックインされた、または不正なデータ
        throw new Error("User already checked in");
      }

      // notified フラグを true に更新（重複送信を防ぐ）
      transaction.update(userRef, {
        notified: true,
        notifiedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    // トランザクション成功後、メール送信（トランザクション外）
    await sendEmergencyEmail(
      name,
      emergencyContactName,
      emergencyContactEmail
    );

    await logNotification(deviceId, emergencyContactEmail, "sent", 1);
    console.log(`Email sent successfully to ${maskEmail(emergencyContactEmail)}`);
  } catch (error: any) {
    if (error.message === "Already notified") {
      console.log(`Skipping ${deviceId}: already notified`);
      return;
    }

    if (error.message === "User already checked in") {
      console.log(`Skipping ${deviceId}: checked in after query (race condition prevented)`);
      return;
    }

    // メール送信失敗時は失敗ログを記録
    // notified=true のまま（次回実行では対象外）
    // 失敗ログは保存されるので、手動で確認・対応可能
    console.error(`Failed to send email for ${deviceId}:`, error);
    await logNotification(deviceId, emergencyContactEmail, "failed", 1);
  }
}

/**
 * Resend APIでメール送信
 */
async function sendEmergencyEmail(
  userName: string,
  contactName: string,
  contactEmail: string
): Promise<void> {
  const apiKey = await getResendApiKey();
  if (!apiKey) {
    throw new Error("Resend API key not configured");
  }

  const resend = new Resend(apiKey);

  await resend.emails.send({
    from: "Living <noreply@7th-bridge.com>",
    to: contactEmail,
    subject: `【Living】${userName}さんの生存確認通知`,
    text: `${contactName}様

${userName}さんが2日間Livingアプリでチェックインしていません。
ご確認をお願いいたします。

---
Living - 生存確認アプリ`,
  });
}

/**
 * 通知ログを記録
 */
async function logNotification(
  deviceId: string,
  sentTo: string,
  status: "sent" | "failed" | "skipped",
  attemptCount: number
): Promise<void> {
  await db.collection("notificationLogs").add({
    deviceId,
    sentTo,
    sentAt: admin.firestore.FieldValue.serverTimestamp(),
    status,
    attemptCount,
  });
}

