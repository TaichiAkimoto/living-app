# Living - 生存確認アプリ

Demumu（死了么）クローン。毎日チェックイン、2日間未チェックで緊急連絡先にメール通知。

## 現在のステータス

**最終更新**: 2026-01-17

### 完了
- iOS/Android: SwiftUI / Jetpack Compose 実装
- Firebase: Cloud Functions + Resend メール送信
- 環境分離: dev/prod 完全分離（Firebase, bundleId, applicationId）
- 認証: Firebase Anonymous Auth（両環境で有効）
- デプロイ: dev/prod 両環境にFirestoreルール・Functions デプロイ済み

### 次にやること
1. 実機テスト（iOS/Android）
2. App Store / Google Play 申請準備

## クイックスタート

```bash
# iOS
cd ios && open Living.xcodeproj

# Firebase Functions
cd firebase/functions && npm install && npm run serve

# Android (dev)
cd android && ./gradlew assembleDevDebug

# Android (prod)
cd android && ./gradlew assembleProdRelease

# Firebase deploy (dev)
cd firebase && firebase use dev && firebase deploy

# Firebase deploy (prod)
cd firebase && firebase use prod && firebase deploy

# Terraform (dev)
cd terraform && terraform plan -var-file=environments/dev.tfvars

# Terraform (prod)
cd terraform && terraform plan -var-file=environments/prod.tfvars
```

## 確定した設計方針

| 項目 | 決定 |
|------|------|
| 通知回数 | **一度だけ**（チェックインでリセット） |
| 端末対応 | **1端末=1ユーザー** |
| タイムゾーン | **UTC統一** |
| 認証 | **Firebase Anonymous Auth**（UID = deviceId） |

## 環境分離

| 環境 | Firebase Project | bundleId (iOS) | applicationId (Android) |
|------|-----------------|----------------|------------------------|
| dev | `livingdev-5cb56` | `com.living.app.dev` | `com.living.app.dev` |
| prod | `living-2b928` | `com.living.app` | `com.living.app` |

## ルール分割構成

| ファイル | 内容 | ロード条件 |
|----------|------|-----------|
| `.claude/rules/design.md` | 設計概要・データ構造 | 常時 |
| `.claude/rules/ios.md` | iOS実装ガイド | `ios/**/*` |
| `.claude/rules/android.md` | Android実装ガイド | `android/**/*` |
| `.claude/rules/firebase.md` | Firebase実装ガイド | `firebase/**/*` |
| `.claude/rules/terraform.md` | Terraform実装ガイド | `terraform/**/*` |

## 参考

- 詳細設計: `docs/DESIGN.md`（図解・シーケンス図）
