terraform {
  required_version = ">= 1.6.0"
  required_providers { google = { source = "hashicorp/google", version = "~> 6.0" } }
  backend "gcs" { bucket = "terraform-state-rahultech-gcp"; prefix = "kidsapp/firestore" }
}
provider "google" { project = var.gcp_project_id; region = var.gcp_region }
resource "google_project_service" "firestore" { service = "firestore.googleapis.com"; disable_on_destroy = false }
resource "google_firestore_database" "main" { name = "kidsapp-${var.env}-db"; location_id = var.gcp_region; type = "FIRESTORE_NATIVE"; depends_on = [google_project_service.firestore] }
resource "google_firestore_index" "child_progress" { project = var.gcp_project_id; database = google_firestore_database.main.name; collection = "child_progress"
  fields { field_path = "parentId"; order = "ASCENDING" }
  fields { field_path = "lastActivityAt"; order = "DESCENDING" }
}
resource "google_firestore_index" "sessions" { project = var.gcp_project_id; database = google_firestore_database.main.name; collection = "activity_sessions"
  fields { field_path = "childId"; order = "ASCENDING" }
  fields { field_path = "completedAt"; order = "DESCENDING" }
}
resource "google_firestore_index" "achievements" { project = var.gcp_project_id; database = google_firestore_database.main.name; collection = "achievements"
  fields { field_path = "childId"; order = "ASCENDING" }
  fields { field_path = "earnedAt"; order = "DESCENDING" }
}
output "database_name" { value = google_firestore_database.main.name }
