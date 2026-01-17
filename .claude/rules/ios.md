---
paths: "ios/**/*"
---

# iOS 実装ガイド

## 技術スタック

| カテゴリ | 選択 |
|----------|------|
| UI | SwiftUI |
| 最小iOS | 17.0 |
| アーキテクチャ | MVVM |

## UIデザイン

### カラー
- 背景: 墨色 `#1a1a1a`
- ボタン: 緑 `#22c55e`
- テキスト: 白 `#ffffff`

### メイン画面レイアウト
```
┌─────────────────────────────────┐
│                                 │
│      ┌─────────────────┐        │
│      │   ✓ チェックイン │        │  ← 緑の大きな円形ボタン
│      └─────────────────┘        │
│                                 │
│   2日間サインインがない場合      │
│   緊急連絡先にメールが届きます   │
│                                 │
│      最終確認: 3時間前           │
│         ⚙️ 設定                 │
└─────────────────────────────────┘
```

## deviceId 永続化

```swift
// Keychainに保存（アプリ再インストールでも維持）
import KeychainAccess

let keychain = Keychain(service: "com.living.app")

func getOrCreateDeviceId() -> String {
    if let existing = keychain["deviceId"] {
        return existing
    }
    let newId = UUID().uuidString
    keychain["deviceId"] = newId
    return newId
}
```

## 初回起動判定

```swift
@AppStorage("hasCompletedSetup") var hasCompletedSetup = false

// 初回: SettingsView → チェックイン後 hasCompletedSetup = true
// 2回目以降: CheckInView 直接表示
```

## Firebase連携

```swift
import FirebaseFirestore

func updateCheckIn(deviceId: String) async throws {
    let db = Firestore.firestore()
    try await db.collection("users").document(deviceId).updateData([
        "lastCheckIn": FieldValue.serverTimestamp(),
        "notified": false
    ])
}
```

## エラーハンドリング

| 状況 | 対応 |
|------|------|
| ネットワークエラー | UserDefaultsに保存、次回起動時に同期 |
| Firestore失敗 | リトライ3回、失敗時はエラー表示 |
