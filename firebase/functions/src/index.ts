import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { Resend } from "resend";

admin.initializeApp();

const db = admin.firestore();

// Resend API Key (Firebase Functions config から取得)
const resendApiKey = functions.config().resend?.api_key || process.env.RESEND_API_KEY;

/**
 * 毎日9:00 UTCに実行される定期チェック
 * 48時間以上チェックインがないユーザーの緊急連絡先にメール送信
 */
export const checkInactiveUsers = functions.pubsub
  .schedule("0 9 * * *")
  .timeZone("UTC")
  .onRun(async () => {
    console.log("Starting inactive users check...");

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

      // 失敗した通知の再試行
      await retryFailedNotifications();

      console.log("Inactive users check completed");
    } catch (error) {
      console.error("Error checking inactive users:", error);
      throw error;
    }
  });

/**
 * 未チェックユーザーの処理
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

  try {
    await sendEmergencyEmail(
      name,
      emergencyContactName,
      emergencyContactEmail
    );

    // 通知済みフラグを更新
    await db.collection("users").doc(deviceId).update({
      notified: true,
    });

    await logNotification(deviceId, emergencyContactEmail, "sent", 1);
    console.log(`Email sent successfully to ${emergencyContactEmail}`);
  } catch (error) {
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
  if (!resendApiKey) {
    throw new Error("Resend API key not configured");
  }

  const resend = new Resend(resendApiKey);

  await resend.emails.send({
    from: "Living <noreply@living.app>",
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

/**
 * 失敗した通知の再試行（最大3回）
 */
async function retryFailedNotifications(): Promise<void> {
  const failedLogs = await db
    .collection("notificationLogs")
    .where("status", "==", "failed")
    .where("attemptCount", "<", 3)
    .orderBy("sentAt", "desc")
    .limit(100)
    .get();

  console.log(`Found ${failedLogs.size} failed notifications to retry`);

  for (const logDoc of failedLogs.docs) {
    const log = logDoc.data();
    const userDoc = await db.collection("users").doc(log.deviceId).get();

    if (!userDoc.exists) {
      console.log(`User ${log.deviceId} not found, skipping retry`);
      continue;
    }

    const userData = userDoc.data();
    if (!userData) continue;

    try {
      await sendEmergencyEmail(
        userData.name,
        userData.emergencyContactName,
        userData.emergencyContactEmail
      );

      // 通知済みフラグを更新
      await db.collection("users").doc(log.deviceId).update({
        notified: true,
      });

      // ログを更新
      await logDoc.ref.update({
        status: "sent",
        attemptCount: log.attemptCount + 1,
      });

      console.log(`Retry successful for ${log.deviceId}`);
    } catch (error) {
      console.error(`Retry failed for ${log.deviceId}:`, error);
      await logDoc.ref.update({
        attemptCount: log.attemptCount + 1,
      });
    }
  }
}
