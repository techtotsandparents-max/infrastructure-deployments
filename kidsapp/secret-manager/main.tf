terraform {
  required_version = ">= 1.6.0"
  required_providers { google = { source = "hashicorp/google", version = "~> 6.0" } }
  backend "gcs" { bucket = "terraform-state-rahultech-gcp"; prefix = "kidsapp/secret-manager" }
}
provider "google" { project = var.gcp_project_id; region = var.gcp_region }
resource "google_project_service" "sm" { service = "secretmanager.googleapis.com"; disable_on_destroy = false }
resource "google_secret_manager_secret" "gemini_key" { secret_id = "kidsapp-gemini-api-key"; replication { auto {} }; depends_on = [google_project_service.sm] }
output "gemini_key_secret_id" { value = google_secret_manager_secret.gemini_key.secret_id }
