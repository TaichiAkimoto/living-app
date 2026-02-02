# メール配信改善ガイド（DMARC/SPF/DKIM）

## 背景

Livingアプリは生存確認通知をResend経由で送信。hotmail.com等のスパムフィルタが厳しいプロバイダーで迷惑メール扱いされる問題が発生。

## DMARC設定（7th-bridge.com）

### 現在の設定（2026-02-02以前）
```
v=DMARC1; p=none;
```
- 問題: 最も緩いポリシー、スパムフィルタが警戒

### 改善後の設定（2026-02-02）
```
v=DMARC1; p=quarantine; pct=25; rua=mailto:dmarc@7th-bridge.com
```

**パラメータ説明:**
- `p=quarantine`: 認証失敗時に迷惑メールフォルダへ振り分け推奨
- `pct=25`: 25%のメールに適用（段階的導入）
- `rua=...`: 集約レポート送信先

### 段階的強化プラン

1. **Phase 1** (現在): `p=quarantine; pct=25`
   - 1週間様子見
   - Resendダッシュボードでバウンス率確認

2. **Phase 2** (1週間後): `p=quarantine; pct=100`
   - 全メールに適用
   - DMARCレポート確認

3. **Phase 3** (最終): `p=reject; pct=100`
   - 認証失敗時は完全拒否
   - 最も厳格なポリシー

## DNS設定方法（お名前.com）

### 確認コマンド
```bash
# DMARC設定確認
dig TXT _dmarc.7th-bridge.com +short

# SPF設定確認
dig TXT 7th-bridge.com +short | grep spf

# DKIM設定確認（Resendの場合）
dig TXT resend._domainkey.7th-bridge.com +short
```

### 反映時間
- 通常: 15分〜1時間
- 最大: 48時間（稀）

## テストメール送信（CLI）

### 準備
```bash
# Resend API Key取得
export RESEND_API_KEY=$(gcloud secrets versions access latest --secret="resend-api-key" --project=living-2b928)
```

### 送信
```bash
curl -X POST https://api.resend.com/emails \
  -H "Authorization: Bearer $RESEND_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "from": "Living <noreply@7th-bridge.com>",
    "to": "test@example.com",
    "subject": "【Living】テスト通知",
    "text": "テストメール本文"
  }'
```

### 配送状況確認
1. Resendダッシュボード: https://resend.com/emails
2. Email IDで検索
3. Delivery Status確認:
   - `Delivered`: 配送成功
   - `Bounced`: 受信拒否
   - `Pending`: 配送中

## hotmail.com固有の問題

### 特徴
- Microsoft運営（Outlook.com, Live.com含む）
- スパムフィルタが特に厳格
- DMARC `p=quarantine` または `p=reject` を強く推奨

### 対処法
1. DMARC強化（上記参照）
2. ユーザーに「差出人セーフリスト」追加を依頼
3. 迷惑メールフォルダ確認を依頼

### 依頼文例
```
お世話になっております。

Livingアプリのシステムテストを実施しており、メール通知が正常に届いているか
確認させていただきたく存じます。

もし可能でしたら、迷惑メールフォルダに「【Living】〇〇さんの生存確認通知」
という件名のメールが届いていないかご確認いただけますと幸いです。

お手数をおかけしますが、何卒よろしくお願いいたします。
```

## トラブルシューティング

### 症状: メールが届かない

1. **FirestoreでnotificationLogs確認**
   ```
   Collection: notificationLogs
   Filter: sentTo == "test@example.com"
   Fields: status, sentAt, attemptCount
   ```

2. **Resendで配送状況確認**
   - https://resend.com/emails
   - Email IDで検索
   - Delivery Statusが `Delivered` なら配送成功

3. **DMARC設定確認**
   ```bash
   dig TXT _dmarc.7th-bridge.com +short
   ```

4. **ドメイン認証確認**
   - https://mxtoolbox.com/dmarc.aspx
   - 7th-bridge.com で検証

### 症状: バウンス率が高い

- DMARC `pct` を下げる（100 → 50 → 25）
- SPF/DKIM設定を再確認
- Resendサポートに問い合わせ

## 参考資料

- [DMARC Quarantine Policy Explained](https://powerdmarc.com/what-is-dmarc-quarantine-policy/)
- [Microsoft DMARC Policy Handling](https://techcommunity.microsoft.com/blog/exchange/announcing-new-dmarc-policy-handling-defaults-for-enhanced-email-security/3878883)
- [Resend Domains Documentation](https://resend.com/docs/dashboard/domains/introduction)

## 関連ファイル

- `firebase/functions/src/index.ts`: メール送信ロジック（Resend API）
- `CLAUDE.md`: 問題履歴と対応状況
