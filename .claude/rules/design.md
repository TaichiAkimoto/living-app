# Living 設計ルール

## 機能（3つだけ）

| 機能 | 内容 |
|------|------|
| チェックイン | 緑のボタンを毎日タップ |
| 通知 | 2日間未チェックで緊急連絡先にメール（一度だけ） |
| 登録 | 名前と緊急連絡先のみ（ログイン不要） |

## 環境分離（Dev / Prod）

| 環境 | Firebase Project | bundleId (iOS) | applicationId (Android) |
|------|-----------------|----------------|------------------------|
| dev | `livingdev-5cb56` | `com.living.app.dev` | `com.living.app.dev` |
| prod | `living-2b928` | `com.living.app` | `com.living.app` |

### Firebase CLI 使い方
```bash
firebase use dev && firebase deploy   # dev環境
firebase use prod && firebase deploy  # prod環境
```

### Cloud Functions 環境ガード
- dev: メール送信は dry-run（実際には送信しない）
- prod: 実際にメール送信

## 認証（Anonymous Auth）

- Firebase Anonymous Auth を使用
- Auth UID を deviceId として使用
- Firestore ルールで `request.auth.uid == deviceId` を要求

## Firestoreデータ構造

```
users/{deviceId}  ← deviceId = Anonymous Auth UID
├── name: string
├── emergencyContactName: string
├── emergencyContactEmail: string
├── lastCheckIn: timestamp
├── createdAt: timestamp
├── notified: boolean          ← 通知済みフラグ

notificationLogs/{logId}
├── deviceId: string
├── sentTo: string
├── sentAt: timestamp
├── status: "sent" | "failed" | "skipped"
├── attemptCount: number       ← 再試行回数（最大3回）
```

## Firestore ルール

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{deviceId} {
      allow read, write: if request.auth != null && request.auth.uid == deviceId;
    }
    match /notificationLogs/{logId} {
      allow read, write: if false;
    }
  }
}
```

## 通知ロジック

### クエリ条件
```typescript
where('lastCheckIn', '<', threshold)  // 48時間前
  .where('notified', '==', false)
```

### チェックイン時
```typescript
lastCheckIn = serverTimestamp()
notified = false  // リセット
```

### 通知送信後
```typescript
notified = true  // 再送信防止
```

## バリデーション

| 項目 | ルール |
|------|--------|
| name | 1〜50文字 |
| emergencyContactName | 1〜50文字 |
| emergencyContactEmail | @を含むメール形式 |

## プロジェクト構成

```
Living/
├── ios/Living/
│   ├── App/LivingApp.swift
│   ├── Views/
│   │   ├── CheckInView.swift
│   │   └── SettingsView.swift
│   ├── Models/UserData.swift
│   ├── Services/FirebaseService.swift
│   └── Firebase/
│       ├── Dev/GoogleService-Info.plist
│       └── Prod/GoogleService-Info.plist
├── android/app/src/
│   ├── main/java/.../living/
│   │   ├── ui/{CheckInScreen,SettingsScreen}.kt
│   │   └── data/UserRepository.kt
│   ├── dev/google-services.json
│   └── prod/google-services.json
├── firebase/
│   ├── .firebaserc           ← dev/prod aliases
│   ├── firestore.rules
│   └── functions/src/index.ts
└── terraform/
    ├── main.tf
    ├── variables.tf
    └── environments/
        ├── dev.tfvars
        └── prod.tfvars
```
