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

## UIデザイン（UI Skills原則）

### カラー
- システムデフォルトを使用
- 背景: `Color(.systemBackground)`
- テキスト: `.primary` / `.secondary`
- アクセント: `Color.accentColor`

### メイン画面レイアウト
```
┌─────────────────────────────────┐
│                                 │
│         Living                  │  ← アプリ名（小さく）
│                                 │
│  ┌───────────────────────────┐  │
│  │       ✓ 確認する          │  │  ← 角丸長方形ボタン
│  └───────────────────────────┘  │     幅いっぱい、高さ56pt
│                                 │
│      最終確認: 3時間前           │
│                                 │
│      2日間未確認で通知           │  ← 説明（secondary color）
│                                 │
│              設定 →             │  ← テキストリンク形式
└─────────────────────────────────┘
```

### アニメーション
- 不要なアニメーションは削除
- 200ms以下のフィードバックのみ許可

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
