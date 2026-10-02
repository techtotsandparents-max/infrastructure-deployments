terraform {
  required_version = ">= 1.6.0"
  required_providers { google = { source = "hashicorp/google", version = "~> 6.0" } }
  backend "gcs" { bucket = "terraform-state-rahultech-gcp"; prefix = "stocksite/secret-manager" }
}
provider "google" { project = var.gcp_project_id; region = var.gcp_region }
resource "google_project_service" "sm" { service = "secretmanager.googleapis.com"; disable_on_destroy = false }
locals {
  secrets = ["zerodha-api-key","zerodha-api-secret","neo4j-password","gemini-api-key"]
}
resource "google_secret_manager_secret" "secrets" {
  for_each  = toset(local.secrets)
  secret_id = "secret-${var.project}-${each.key}"
  replication { auto {} }
  depends_on = [google_project_service.sm]
}
output "secret_ids" { value = { for k, v in google_secret_manager_secret.secrets : k => v.secret_id } }
