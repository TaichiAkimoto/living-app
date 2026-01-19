# Living - 生存確認アプリ

Demumu（死了么）クローン。毎日チェックイン、2日間未チェックで緊急連絡先にメール通知。

## 現在のステータス

**最終更新**: 2026-01-19 15:45

### 完了
- iOS/Android: SwiftUI / Jetpack Compose 実装
- Firebase: Cloud Functions + Resend メール送信
- 環境分離: dev/prod 完全分離（Firebase, bundleId, applicationId）
- 認証: Firebase Anonymous Auth（両環境で有効）
- デプロイ: dev/prod 両環境にFirestoreルール・Functions デプロイ済み
- **UI/アニメーション実装**:
  - スプラッシュ画面（2つの点が繋がるアニメーション）
  - オンボーディング（3画面スワイプ）
  - チェックイン成功時の波動アニメーション
  - アプリアイコン（◯───◯モチーフ）
- **アプリ名変更**: Living → 「生きろ。」
- **認証リトライ＆エラー画面** (2026-01-18)
- **ビルド確認済み**: Android prod release ✅ / iOS dev ✅
- **iOS自動入力対応** (2026-01-19): SettingsViewにtextContentType追加
- **アカウント調査完了** (2026-01-19): 使用可能なアカウント特定済み
- **Apple ID作成** (2026-01-19): bodhy.akimoto@gmail.com
- **Apple Developer Program 支払い完了** (2026-01-19): $99、注文番号 W1533090277

### 次にやること（次回セッション）

1. **iOS: Apple Developer アクティベーション確認**
   - ⏳ 最長48時間待ち（支払い完了済み）
   - アクティブになったら → App Store Connect でアプリ登録
   - Xcode Archive → アップロード → 審査提出

2. **Android: Google Play Console 登録完了** ($25未払い)
   - デベロッパー名: Taichi A.（設定済み）
   - お支払いプロファイル作成（国：日本）
   - $25 支払い → AABアップロード → 審査提出

### ストア登録状況

#### Apple Developer Program ✅ 支払い完了
- **使用アカウント**: bodhy.akimoto@gmail.com
- **費用**: $99（年払い）✅ 支払済
- **注文番号**: W1533090277
- **状態**: ⏳ アクティベーション待ち（最長48時間）

#### Google Play Console 🔄 登録途中
- **使用アカウント**: bodhy.akimoto@gmail.com
- **デベロッパー名**: Taichi A.
- **費用**: $25（一回払い）❌ 未払い
- **状態**: お支払いプロファイル作成 → 支払いが必要

#### 登録費用合計
| プラットフォーム | 費用 | 状態 |
|-----------------|------|------|
| Apple Developer | $99 | ✅ 支払済 |
| Google Play | $25 | ❌ 未払い |
| **合計** | **$124** | |

### iOS署名設定（開発用）
- Team: 太一 稀元 (Personal Team)
- Bundle ID: `com.living.app.dev`（dev環境）
- Signing Certificate: Apple Development: italyitalienitalia@gmail.com
- 初回実機インストール時: 設定 > 一般 > VPNとデバイス管理 から信頼が必要

### 既知の問題
- 設定画面の「始める」ボタンを押しても反応しない場合がある
  - 状態管理は修正済み（AppState + onCompleteコールバック方式）
  - Firebase保存の成功/失敗を確認する必要あり

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
