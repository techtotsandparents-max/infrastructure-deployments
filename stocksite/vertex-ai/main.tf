terraform {
  required_version = ">= 1.6.0"
  required_providers { google = { source = "hashicorp/google", version = "~> 6.0" } }
  backend "gcs" { bucket = "terraform-state-rahultech-gcp"; prefix = "stocksite/vertex-ai" }
}
provider "google" { project = var.gcp_project_id; region = var.gcp_region }
resource "google_project_service" "vertex" { service = "aiplatform.googleapis.com"; disable_on_destroy = false }
resource "google_vertex_ai_dataset" "training" { display_name = "stocksite-training-data"; metadata_schema_uri = "gs://google-cloud-aiplatform/schema/dataset/metadata/tabular_1.0.0.yaml"; region = var.gcp_region; depends_on = [google_project_service.vertex] }
resource "google_vertex_ai_endpoint" "prediction" { name = "ep-${var.project}-prediction"; display_name = "Stock Prediction Endpoint"; location = var.gcp_region; depends_on = [google_project_service.vertex] }
output "dataset_name"   { value = google_vertex_ai_dataset.training.name }
output "endpoint_name"  { value = google_vertex_ai_endpoint.prediction.name }
