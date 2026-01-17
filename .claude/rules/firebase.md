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
| Firebase Auth | Anonymous Auth（UID = deviceId） |
| Resend | メール送信API |

## 環境分離

| 環境 | Firebase Project | 用途 |
|------|-----------------|------|
| dev | `livingdev-5cb56` | 開発・テスト |
| prod | `living-2b928` | 本番 |

### .firebaserc
```json
{
  "projects": {
    "default": "living-2b928",
    "dev": "livingdev-5cb56",
    "prod": "living-2b928"
  }
}
```

### 使い方
```bash
firebase use dev && firebase deploy   # dev環境
firebase use prod && firebase deploy  # prod環境
```

## Firestoreルール（Anonymous Auth対応）

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // users: Anonymous Auth UID でスコープ制限
    match /users/{deviceId} {
      allow read, write: if request.auth != null && request.auth.uid == deviceId;
    }

    // notificationLogs: Functions専用
    match /notificationLogs/{logId} {
      allow read, write: if false;
    }
  }
}
```

## Cloud Functions

### 環境判定
```typescript
// 環境判定（ログ出力用）
const ENV = functions.config().env?.name || process.env.FUNCTIONS_ENV || "prod";
```

> **Note**: dev/prod両環境で実際にメール送信を行う。Resend APIキーは両プロジェクトのSecret Managerに設定済み。

### checkInactiveUsers

```typescript
export const checkInactiveUsers = functions.pubsub
  .schedule('0 9 * * *')  // 毎日9:00 UTC
  .timeZone('UTC')
  .onRun(async () => {
    const threshold = new Date(Date.now() - 48 * 60 * 60 * 1000);

    const snapshot = await db.collection('users')
      .where('lastCheckIn', '<', threshold)
      .where('notified', '==', false)
      .get();

    for (const doc of snapshot.docs) {
      await processInactiveUser(doc.id, doc.data());
    }

    await retryFailedNotifications();
  });
```

## 再試行ロジック

```typescript
// 失敗した通知を再試行（最大3回）
const failedLogs = await db.collection('notificationLogs')
  .where('status', '==', 'failed')
  .where('attemptCount', '<', 3)
  .get();
```

## Secret Manager

Resend API Key は Secret Manager で管理:
```bash
# Terraform で設定済み
# terraform/secrets.tf 参照
```

## デプロイ手順

### dev環境
```bash
cd firebase
firebase use dev
firebase deploy --only firestore:rules
firebase deploy --only functions
```

### prod環境
```bash
cd firebase
firebase use prod
firebase deploy --only firestore:rules
firebase deploy --only functions
```
