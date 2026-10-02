terraform {
  required_version = ">= 1.6.0"
  required_providers { google = { source = "hashicorp/google", version = "~> 6.0" } }
  backend "gcs" { bucket = "terraform-state-rahultech-gcp"; prefix = "kidsapp/storage" }
}
provider "google" { project = var.gcp_project_id; region = var.gcp_region }
resource "google_storage_bucket" "models" {
  name = "${var.gcp_project_id}-ml-models"; location = "ASIA"; force_destroy = false; uniform_bucket_level_access = true
  versioning { enabled = true }
  lifecycle_rule { condition { age = 90 }; action { type = "SetStorageClass"; storage_class = "NEARLINE" } }
}
resource "google_storage_bucket" "assets" { name = "${var.gcp_project_id}-child-assets"; location = "ASIA"; force_destroy = false; uniform_bucket_level_access = true; lifecycle_rule { condition { age = 365 }; action { type = "Delete" } } }
resource "google_storage_bucket_iam_member" "models_public" { bucket = google_storage_bucket.models.name; role = "roles/storage.objectViewer"; member = "allUsers" }
output "models_bucket"  { value = google_storage_bucket.models.name }
output "assets_bucket"  { value = google_storage_bucket.assets.name }
