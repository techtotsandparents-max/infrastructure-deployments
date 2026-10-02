variable "project_id" { type = string }
variable "region" { type = string }
variable "service_name" { type = string }
variable "image" { type = string }
variable "min_instances" { type = number; default = 0 }
variable "max_instances" { type = number; default = 5 }
variable "cpu" { type = string; default = "1" }
variable "memory" { type = string; default = "512Mi" }
variable "allow_unauthenticated" { type = bool; default = true }
variable "env_vars" { type = map(string); default = {} }
variable "labels" { type = map(string); default = {} }

resource "google_cloud_run_v2_service" "service" {
  name     = var.service_name
  location = var.region
  project  = var.project_id
  ingress  = "INGRESS_TRAFFIC_ALL"
  labels   = var.labels

  template {
    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }
    containers {
      image = var.image
      resources {
        limits = {
          cpu    = var.cpu
          memory = var.memory
        }
        cpu_idle = true
      }
      dynamic "env" {
        for_each = var.env_vars
        content {
          name  = env.key
          value = env.value
        }
      }
    }
  }
}

resource "google_cloud_run_v2_service_iam_member" "public_access" {
  count    = var.allow_unauthenticated ? 1 : 0
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.service.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

output "service_url" {
  value = google_cloud_run_v2_service.service.uri
}

output "service_id" {
  value = google_cloud_run_v2_service.service.id
}
