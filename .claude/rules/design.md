# Living 設計ルール

## 機能（3つだけ）

| 機能 | 内容 |
|------|------|
| チェックイン | 緑のボタンを毎日タップ |
| 通知 | 2日間未チェックで緊急連絡先にメール（一度だけ） |
| 登録 | 名前と緊急連絡先のみ（ログイン不要） |

## Firestoreデータ構造

```
users/{deviceId}
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
│   ├── LivingApp.swift
│   ├── Views/
│   │   ├── CheckInView.swift
│   │   └── SettingsView.swift
│   ├── Models/UserData.swift
│   └── Services/FirebaseService.swift
├── android/app/src/main/java/.../living/
│   ├── ui/{CheckInScreen,SettingsScreen}.kt
│   └── data/UserRepository.kt
└── firebase/functions/src/
    ├── index.ts
    └── checkInactiveUsers.ts
```
