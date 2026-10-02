terraform {
  required_version = ">= 1.6.0"
  required_providers { google = { source = "hashicorp/google", version = "~> 6.0" } }
  backend "gcs" { bucket = "terraform-state-rahultech-gcp"; prefix = "stocksite/cloud-run-backend" }
}
provider "google" { project = var.gcp_project_id; region = var.gcp_region }

resource "google_service_account" "backend" { account_id = "sa-${var.project}-backend"; display_name = "Stock Site Backend Service Account" }
resource "google_project_iam_member" "roles" {
  for_each = toset(["roles/datastore.user","roles/bigquery.dataEditor","roles/secretmanager.secretAccessor","roles/aiplatform.user","roles/pubsub.editor"])
  project  = var.gcp_project_id; role = each.value; member = "serviceAccount:${google_service_account.backend.email}"
}
resource "google_cloud_run_v2_service" "backend" {
  name     = "cr-${var.project}-backend-${var.env}"
  location = var.gcp_region
  ingress  = "INGRESS_TRAFFIC_ALL"
  labels   = var.labels
  template {
    service_account = google_service_account.backend.email
    scaling { min_instance_count = 0; max_instance_count = var.max_instances }
    containers {
      image = var.backend_image
      resources { limits = { cpu = var.cpu; memory = var.memory }; cpu_idle = true }
      env { name = "ENVIRONMENT";        value = var.env }
      env { name = "GCP_PROJECT";        value = var.gcp_project_id }
      env { name = "FIRESTORE_DATABASE"; value = var.firestore_db }
      env { name = "BQ_DATASET";         value = var.bq_dataset }
      env { name = "PUBSUB_TICK_TOPIC";  value = var.pubsub_tick_topic }
    }
    vpc_access { connector = var.vpc_connector_id; egress = "PRIVATE_RANGES_ONLY" }
  }
}
resource "google_cloud_run_v2_service_iam_member" "public" { project = var.gcp_project_id; location = var.gcp_region; name = google_cloud_run_v2_service.backend.name; role = "roles/run.invoker"; member = "allUsers" }
output "backend_url"            { value = google_cloud_run_v2_service.backend.uri }
output "backend_sa_email"       { value = google_service_account.backend.email }
