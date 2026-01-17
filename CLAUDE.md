# Living - 生存確認アプリ

Demumu（死了么）クローン。毎日チェックイン、2日間未チェックで緊急連絡先にメール通知。

## 現在のステータス

**最終更新**: 2026-01-17

### 完了
- iOS: SwiftUI実装（CheckInView, SettingsView, FirebaseService）
- Android: Jetpack Compose実装（同等機能）
- Firebase: Cloud Functions（2日間チェック + Resendメール送信）

### 次にやること
1. Firebaseプロジェクト作成・設定
2. GoogleService-Info.plist / google-services.json 追加
3. Resend APIキー設定
4. 実機テスト

## クイックスタート

```bash
# iOS
cd ios && open Living.xcodeproj

# Firebase Functions
cd firebase/functions && npm install && npm run serve

# Android
cd android && ./gradlew assembleDebug
```

## 確定した設計方針

| 項目 | 決定 |
|------|------|
| 通知回数 | **一度だけ**（チェックインでリセット） |
| 端末対応 | **1端末=1ユーザー** |
| タイムゾーン | **UTC統一** |
| 認証 | **なし**（deviceIdのみ） |

## ルール分割構成

| ファイル | 内容 | ロード条件 |
|----------|------|-----------|
| `.claude/rules/design.md` | 設計概要・データ構造 | 常時 |
| `.claude/rules/ios.md` | iOS実装ガイド | `ios/**/*` |
| `.claude/rules/firebase.md` | Firebase実装ガイド | `firebase/**/*` |
| `docs/DESIGN.md` | 詳細設計（図解） | 手動参照 |

## 参考

- 元アプリ: Demumu（死了么）
- 詳細設計: `docs/DESIGN.md`
