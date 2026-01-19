# Living - 生存確認アプリ

Demumu（死了么）クローン。毎日チェックイン、2日間未チェックで緊急連絡先にメール通知。

## 現在のステータス

**最終更新**: 2026-01-19

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
- **認証リトライ＆エラー画面** (2026-01-18):
  - iOS/Android両方で認証失敗時のリトライロジック実装
  - 指数バックオフ (1s→2s→4s)、最大3回
  - エラー画面追加（グレー2点 + 再試行ボタン）
- **ビルド確認済み**:
  - Android prod release: ✅ BUILD SUCCESSFUL
  - iOS dev (署名設定済み): ✅ Personal Team設定完了
- **Google Play Console 返金依頼送信済み** (2026-01-18):
  - 旧アカウント（italyitalienitalia@gmail.com）は非アクティブで閉鎖済み
  - 登録料$25が2回課金（$50）→ 重複課金分の返金依頼をGoogleサポートに送信
- **新メールアドレス作成済み**: akimototaichi@gmail.com（iOS/Android両方で使用予定）

### 進行中 (2026-01-19)

#### Google Play Console 登録 - 一時停止中
- **ブラウザタブ**: 「あなたの情報」ページで停止中（Chromeタブを保持）
- **完了したステップ**:
  1. ✅ akimototaichi@gmail.com でログイン
  2. ✅ 2段階認証を有効化
  3. ✅ 個人用アカウントを選択
  4. ✅ デベロッパー名: "Taichi A."
  5. ✅ お支払いプロファイルをリンク（住所更新済み）
  6. ✅ 公開デベロッパープロフィール設定
  7. ✅ 公開メールアドレス: akimototaichi@gmail.com（検証済み）
  8. 🔄 「あなたの情報」ページ入力中 → ここで一時停止
- **残りのステップ**: アプリ、Googleからの連絡方法、利用規約、$25支払い
- **再開方法**: Chromeタブが開いたまま → 「次へ」で続行可能

### 次にやること
1. **Apple Developer Program 登録可否を調査**（akimototaichi@gmail.comで）
2. Google Play Console 登録を完了（$25支払い）
3. Apple Developer Program 登録（$99/年）
4. AAB (Android App Bundle) ビルド: `./gradlew bundleProdRelease`
5. Google Play Console でアプリ作成・審査提出
6. Xcode Archive → App Store Connect 審査提出

### ストア登録状況

**新アカウント**: akimototaichi@gmail.com（iOS/Android両方で使用）

#### Google Play Console
- **旧アカウント**: italyitalienitalia@gmail.com → 2025年3月閉鎖
- **問題**: 同じメールでの再登録不可（Googleポリシー）
- **状態**: 🔄 登録進行中（一時停止）

#### Apple Developer Program
- **旧アカウント**: italyitalienitalia@gmail.com → 別組織のaccount holderエラー
- **問題**: 既存の組織に紐づいているため使用不可
- **状態**: 📋 登録可否を調査中

#### 登録費用
| プラットフォーム | 費用 | 支払い |
|-----------------|------|--------|
| Google Play | $25 | 一回払い |
| Apple Developer | $99 | 年払い |

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
