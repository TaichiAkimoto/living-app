variable "environment" {
  description = "Environment name (dev or prod)"
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be 'dev' or 'prod'."
  }
}

variable "project_id" {
  description = "GCP/Firebase Project ID"
  type        = string
}

variable "region" {
  description = "Default GCP region"
  type        = string
  default     = "asia-northeast1"
}

variable "firestore_location" {
  description = "Firestore database location"
  type        = string
  default     = "asia-northeast1"
}

variable "resend_api_key" {
  description = "Resend API key for email sending"
  type        = string
  sensitive   = true
  default     = ""
}
