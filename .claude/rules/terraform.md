---
paths: "terraform/**/*"
---

# Terraform 実装ガイド

## 環境分離

| 環境 | tfvars | Firebase Project |
|------|--------|-----------------|
| dev | `environments/dev.tfvars` | livingdev-5cb56 |
| prod | `environments/prod.tfvars` | living-2b928 |

## 使い方

```bash
# dev環境
cd terraform
terraform workspace select dev || terraform workspace new dev
terraform plan -var-file=environments/dev.tfvars
terraform apply -var-file=environments/dev.tfvars

# prod環境
terraform workspace select prod || terraform workspace new prod
terraform plan -var-file=environments/prod.tfvars
terraform apply -var-file=environments/prod.tfvars
```

## 管理対象

| リソース | Terraform | Firebase CLI |
|----------|-----------|--------------|
| Firestore Database | ✅ | - |
| Firestore Indexes | ✅ | - |
| Firestore Rules | - | ✅ |
| Cloud Functions | - | ✅ |
| Secret Manager | ✅ | - |

> **Note**: Firestoreルールは Firebase CLI でデプロイ（Terraformと競合回避）

## ファイル構成

```
terraform/
├── main.tf           # Provider設定
├── variables.tf      # 変数定義（environment, project_id, region）
├── firestore.tf      # Firestore DB + Indexes
├── secrets.tf        # Secret Manager（Resend APIキー）
└── environments/
    ├── dev.tfvars    # dev環境設定
    └── prod.tfvars   # prod環境設定
```

## 変数

```hcl
variable "environment" {
  type    = string  # "dev" or "prod"
}

variable "project_id" {
  type    = string  # Firebase Project ID
}

variable "region" {
  type    = string
  default = "asia-northeast1"
}

variable "resend_api_key" {
  type      = string
  sensitive = true
}
```

## インデックス

```hcl
# users: 未チェック + 未通知ユーザー検索用
resource "google_firestore_index" "users_inactive" {
  collection = "users"
  fields {
    field_path = "lastCheckIn"
    order      = "ASCENDING"
  }
  fields {
    field_path = "notified"
    order      = "ASCENDING"
  }
}

# notificationLogs: 失敗通知の再試行用
resource "google_firestore_index" "notification_logs_retry" {
  collection = "notificationLogs"
  fields {
    field_path = "status"
    order      = "ASCENDING"
  }
  fields {
    field_path = "attemptCount"
    order      = "ASCENDING"
  }
  fields {
    field_path = "sentAt"
    order      = "DESCENDING"
  }
}
```
