# Secret Manager for Resend API Key
resource "google_secret_manager_secret" "resend_api_key" {
  secret_id = "resend-api-key"
  project   = var.project_id

  replication {
    auto {}
  }

  depends_on = [google_project_service.services]
}

resource "google_secret_manager_secret_version" "resend_api_key" {
  secret      = google_secret_manager_secret.resend_api_key.id
  secret_data = var.resend_api_key

  depends_on = [google_secret_manager_secret.resend_api_key]
}

# Cloud Functions Service Account に Secret へのアクセス権限を付与
resource "google_secret_manager_secret_iam_member" "functions_access" {
  secret_id = google_secret_manager_secret.resend_api_key.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.project_id}@appspot.gserviceaccount.com"

  depends_on = [google_secret_manager_secret.resend_api_key]
}
