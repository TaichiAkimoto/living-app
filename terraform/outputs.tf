output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
}

output "firestore_database" {
  description = "Firestore database name"
  value       = google_firestore_database.main.name
}

output "firestore_location" {
  description = "Firestore database location"
  value       = google_firestore_database.main.location_id
}
