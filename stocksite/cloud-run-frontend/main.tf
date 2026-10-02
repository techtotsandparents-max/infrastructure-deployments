terraform {
  required_version = ">= 1.6.0"
  required_providers { google = { source = "hashicorp/google", version = "~> 6.0" } }
  backend "gcs" { bucket = "terraform-state-rahultech-gcp"; prefix = "stocksite/cloud-run-frontend" }
}
provider "google" { project = var.gcp_project_id; region = var.gcp_region }

resource "google_project_service" "run" { service = "run.googleapis.com"; disable_on_destroy = false }

resource "google_cloud_run_v2_service" "frontend" {
  name     = "cr-${var.project}-frontend-${var.env}"
  location = var.gcp_region
  ingress  = "INGRESS_TRAFFIC_ALL"
  labels   = var.labels

  template {
    scaling { min_instance_count = 0; max_instance_count = var.max_instances }
    containers {
      image = var.frontend_image
      resources { limits = { cpu = var.cpu; memory = var.memory }; cpu_idle = true }
      env { name = "NODE_ENV"; value = "production" }
      env { name = "BACKEND_URL"; value = var.backend_url }
    }
    vpc_access { connector = var.vpc_connector_id; egress = "PRIVATE_RANGES_ONLY" }
  }
  depends_on = [google_project_service.run]
}

resource "google_cloud_run_v2_service_iam_member" "public" {
  project  = var.gcp_project_id; location = var.gcp_region
  name     = google_cloud_run_v2_service.frontend.name
  role     = "roles/run.invoker"; member = "allUsers"
}

output "frontend_url" { value = google_cloud_run_v2_service.frontend.uri }
