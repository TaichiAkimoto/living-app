# Firestore Database
resource "google_firestore_database" "main" {
  provider = google-beta
  project  = var.project_id
  name     = "(default)"
  location_id = var.firestore_location
  type     = "FIRESTORE_NATIVE"

  depends_on = [google_project_service.services]
}

# Firestore Security Rules
# NOTE: Rules are deployed via Firebase CLI (firebase deploy --only firestore:rules)
# This avoids conflicts between Terraform and Firebase CLI deployments.
# See: firebase/firestore.rules

# Firestore Indexes (複合インデックス)
resource "google_firestore_index" "users_inactive" {
  provider   = google-beta
  project    = var.project_id
  database   = google_firestore_database.main.name
  collection = "users"

  fields {
    field_path = "lastCheckIn"
    order      = "ASCENDING"
  }

  fields {
    field_path = "notified"
    order      = "ASCENDING"
  }

  depends_on = [google_firestore_database.main]
}

resource "google_firestore_index" "notification_logs_retry" {
  provider   = google-beta
  project    = var.project_id
  database   = google_firestore_database.main.name
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

  depends_on = [google_firestore_database.main]
}
