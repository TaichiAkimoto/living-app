# Living - 生存確認アプリ

Demumu（死了么）クローン。毎日チェックイン、2日間未チェックで緊急連絡先にメール通知。

## 現在のステータス

**最終更新**: 2026-01-21 23:20

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
- **Apple Developer Program** (2026-01-21): ✅ アクティベーション完了
- **App Store Connect アプリ登録** (2026-01-21):
  - App ID: 6758099608
  - Bundle ID: `com.taichiakimoto.living`（`com.living.app`は使用不可だった）
  - アプリ名: 生きろ。
  - SKU: com-living-app
- **App Store Connect メタデータ入力** (2026-01-21):
  - 説明文、キーワード、サポートURL ✅
  - プライバシーポリシーURL: https://taichiakimoto.github.io/living-app/privacy-policy ✅
  - プライバシー設定（データ収集）公開 ✅
  - 著作権、App Review連絡先 ✅
- **スクリーンショット撮影** (2026-01-21):
  - iPhone 16 Pro Max (6.7"): `screenshots/iphone_6_7_checkin.png` (1320x2868)
  - iPhone 16 Plus (6.5"): `screenshots/iphone_6_5_checkin.png` (1290x2796)
- **Google Play Console 重複課金返金依頼送信** (2026-01-19): フォーム送信完了
- **Apple Distribution証明書** (2026-01-21): ✅ 作成＆インストール完了
  - Certificate Name: Taichi Akimoto
  - Certificate Type: Distribution
  - Team ID: N87AGP76YT
  - 有効期限: 2027/01/21
- **Xcode署名設定更新** (2026-01-21): DEVELOPMENT_TEAM = N87AGP76YT に変更済み

### 次にやること（次回セッション）

1. **iOS: スクリーンショット撮り直し** ⚠️
   - 現在のスクリーンショット (1290×2796) はApp Store Connectで受け入れられない
   - 必要なサイズ: 1242×2688 または 1284×2778（6.5インチ用）
   - iPhone 14 Plus (1284×2778) のシミュレータをインストールして撮り直す
   - または、古いiOSランタイムをダウンロードして対応するシミュレータを使用

2. **iOS: Xcodeアーカイブ & アップロード**
   - Xcode → Product → Archive
   - Organizer → Distribute App → App Store Connect
   - Bundle ID: `com.taichiakimoto.living`
   - Distribution証明書: Apple Distribution: Taichi Akimoto (N87AGP76YT) ✅

3. **iOS: 審査提出**
   - App Store Connectでビルド選択 → 審査に提出

4. **Android: Google Play Console 登録完了**
   - 重複課金返金依頼送信済み → 返信待ち
   - 返金確認後、正規の$25を支払い → AABアップロード → 審査提出

### ストア登録状況

#### Apple Developer Program ✅ アクティブ
- **使用アカウント**: bodhy.akimoto@gmail.com
- **費用**: $99（年払い）✅ 支払済
- **注文番号**: W1533090277
- **状態**: ✅ アクティベーション完了

#### App Store Connect 🔄 提出準備中
- **App ID**: 6758099608
- **Bundle ID**: `com.taichiakimoto.living`
- **バージョン**: 1.0.0
- **状態**: 提出準備中（スクリーンショット＆ビルドアップロード待ち）

#### Google Play Console 🔄 登録途中
- **使用アカウント**: bodhy.akimoto@gmail.com
- **デベロッパー名**: Taichi A.
- **デベロッパー アカウント ID**: 5968496600017672432
- **費用**: $25（一回払い）❌ 未払い（重複課金で$50課金済み）
- **状態**: 返金依頼送信済み（2026-01-19）→ 2営業日以内に返信予定
- **返金依頼**: italyitalienitalia@gmail.com 宛に返信が届く予定

#### 登録費用合計
| プラットフォーム | 費用 | 状態 |
|-----------------|------|------|
| Apple Developer | $99 | ✅ 支払済 |
| Google Play | $25 | ❌ 未払い |
| **合計** | **$124** | |

### iOS署名設定

#### 開発用 (dev)
- Team: 太一 稀元 (Personal Team)
- Bundle ID: `com.living.app.dev`
- Signing Certificate: Apple Development: italyitalienitalia@gmail.com
- 初回実機インストール時: 設定 > 一般 > VPNとデバイス管理 から信頼が必要

#### App Store配布用 (prod) ✅ 設定完了
- Team: Taichi Akimoto (N87AGP76YT)
- Bundle ID: `com.taichiakimoto.living`
- Signing Certificate: Apple Distribution: Taichi Akimoto (N87AGP76YT)
- XcodeのDEVELOPMENT_TEAM: N87AGP76YT（project.pbxprojで設定済み）

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
