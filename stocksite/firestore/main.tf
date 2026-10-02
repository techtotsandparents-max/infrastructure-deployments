terraform {
  required_version = ">= 1.6.0"
  required_providers { google = { source = "hashicorp/google", version = "~> 6.0" } }
  backend "gcs" { bucket = "terraform-state-rahultech-gcp"; prefix = "stocksite/firestore" }
}
provider "google" { project = var.gcp_project_id; region = var.gcp_region }
resource "google_project_service" "firestore" { service = "firestore.googleapis.com"; disable_on_destroy = false }
resource "google_firestore_database" "main" { name = "${var.project}-${var.env}-db"; location_id = var.gcp_region; type = "FIRESTORE_NATIVE"; depends_on = [google_project_service.firestore] }
resource "google_firestore_index" "portfolio_by_user" { project = var.gcp_project_id; database = google_firestore_database.main.name; collection = "portfolio"
  fields { field_path = "userId"; order = "ASCENDING" }
  fields { field_path = "updatedAt"; order = "DESCENDING" }
}
resource "google_firestore_index" "agent_state_by_type" { project = var.gcp_project_id; database = google_firestore_database.main.name; collection = "agent_states"
  fields { field_path = "agentType"; order = "ASCENDING" }
  fields { field_path = "createdAt"; order = "DESCENDING" }
}
output "database_name" { value = google_firestore_database.main.name }
output "database_id"   { value = google_firestore_database.main.id }
