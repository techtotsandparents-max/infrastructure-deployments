terraform {
  required_version = ">= 1.6.0"
  required_providers { google = { source = "hashicorp/google", version = "~> 6.0" } }
  backend "gcs" { bucket = "terraform-state-rahultech-gcp"; prefix = "kidsapp/cloud-functions" }
}
provider "google" { project = var.gcp_project_id; region = var.gcp_region }

resource "google_project_service" "apis" {
  for_each = toset(["cloudfunctions.googleapis.com","cloudbuild.googleapis.com","run.googleapis.com","eventarc.googleapis.com"])
  service  = each.value; disable_on_destroy = false
}

resource "google_service_account" "functions" { account_id = "sa-kidsapp-functions"; display_name = "Kids App Cloud Functions SA" }
resource "google_project_iam_member" "roles" {
  for_each = toset(["roles/datastore.user","roles/secretmanager.secretAccessor","roles/storage.objectAdmin","roles/aiplatform.user"])
  project  = var.gcp_project_id; role = each.value; member = "serviceAccount:${google_service_account.functions.email}"
}

resource "google_storage_bucket" "fn_source" { name = "${var.gcp_project_id}-fn-source"; location = "ASIA"; uniform_bucket_level_access = true; force_destroy = true }

locals {
  functions = {
    generate-questions  = { entry_point = "generateQuestions"; memory = "256M"; timeout = 60 }
    adaptive-engine     = { entry_point = "processActivityResult"; memory = "256M"; timeout = 30 }
    parent-dashboard    = { entry_point = "getParentDashboard"; memory = "256M"; timeout = 30 }
  }
}

resource "google_cloudfunctions2_function" "fn" {
  for_each = local.functions
  name     = "fn-kidsapp-${each.key}"
  location = var.gcp_region
  build_config { runtime = "nodejs20"; entry_point = each.value.entry_point; source { storage_source { bucket = google_storage_bucket.fn_source.name; object = "functions/${each.key}.zip" } } }
  service_config {
    min_instance_count    = 0
    max_instance_count    = var.max_instances
    available_memory      = each.value.memory
    timeout_seconds       = each.value.timeout
    service_account_email = google_service_account.functions.email
    environment_variables = { GCP_PROJECT_ID = var.gcp_project_id; FIRESTORE_DATABASE = var.firestore_database; GEMINI_MODEL = "gemini-2.0-flash" }
  }
  depends_on = [google_project_service.apis]
  lifecycle { ignore_changes = [build_config[0].source] }
}

output "function_urls" { value = { for k, v in google_cloudfunctions2_function.fn : k => v.url } }
output "functions_sa"  { value = google_service_account.functions.email }
