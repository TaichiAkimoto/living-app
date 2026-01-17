---
paths: "firebase/**/*"
---

# Firebase 実装ガイド

## サービス構成

| サービス | 用途 |
|----------|------|
| Cloud Firestore | データ保存 |
| Cloud Functions | 2日間チェック・メール送信 |
| Cloud Scheduler | 毎日バッチ実行 |
| Resend | メール送信API |

## Firestoreルール

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // users: deviceIdで認証なしアクセス
    match /users/{deviceId} {
      allow read, write: if true;  // シンプル優先
    }

    // notificationLogs: Functions専用
    match /notificationLogs/{logId} {
      allow read: if false;
      allow write: if false;
    }
  }
}
```

## Cloud Functions

### checkInactiveUsers.ts

```typescript
import * as functions from 'firebase-functions';
import { Firestore } from 'firebase-admin/firestore';
import { Resend } from 'resend';

const db = new Firestore();
const resend = new Resend(process.env.RESEND_API_KEY);

export const scheduledCheck = functions.pubsub
  .schedule('0 9 * * *')  // 毎日9:00 UTC
  .timeZone('UTC')
  .onRun(async () => {
    const threshold = new Date(Date.now() - 48 * 60 * 60 * 1000);

    const snapshot = await db.collection('users')
      .where('lastCheckIn', '<', threshold)
      .where('notified', '==', false)
      .get();

    for (const doc of snapshot.docs) {
      const user = doc.data();
      await sendEmergencyEmail(doc.id, user);
    }
  });
```

### sendEmail.ts

```typescript
async function sendEmergencyEmail(deviceId: string, user: any) {
  const { name, emergencyContactEmail, emergencyContactName } = user;

  // バリデーション
  if (!emergencyContactEmail || !emergencyContactEmail.includes('@')) {
    await logNotification(deviceId, emergencyContactEmail, 'skipped', 0);
    return;
  }

  try {
    await resend.emails.send({
      from: 'Living <noreply@living.app>',
      to: emergencyContactEmail,
      subject: `【Living】${name}さんの生存確認通知`,
      text: `${emergencyContactName}様\n\n${name}さんが2日間Livingアプリでチェックインしていません。\nご確認をお願いいたします。\n\n---\nLiving - 生存確認アプリ`
    });

    // 成功: notified = true に更新
    await db.collection('users').doc(deviceId).update({ notified: true });
    await logNotification(deviceId, emergencyContactEmail, 'sent', 1);

  } catch (error) {
    await logNotification(deviceId, emergencyContactEmail, 'failed', 1);
  }
}

async function logNotification(
  deviceId: string,
  sentTo: string,
  status: string,
  attemptCount: number
) {
  await db.collection('notificationLogs').add({
    deviceId,
    sentTo,
    sentAt: new Date(),
    status,
    attemptCount
  });
}
```

## 再試行ロジック

```typescript
// 失敗した通知を再試行（最大3回）
const failedLogs = await db.collection('notificationLogs')
  .where('status', '==', 'failed')
  .where('attemptCount', '<', 3)
  .get();
```

## 環境変数

```bash
# .env
RESEND_API_KEY=re_xxxxxxxxxxxx
```

```bash
# Firebase Functions設定
firebase functions:config:set resend.api_key="re_xxxxxxxxxxxx"
```
