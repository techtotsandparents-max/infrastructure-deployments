terraform {
  required_version = ">= 1.6.0"
  required_providers { google = { source = "hashicorp/google", version = "~> 6.0" } }
  backend "gcs" { bucket = "terraform-state-rahultech-gcp"; prefix = "stocksite/pubsub" }
}
provider "google" { project = var.gcp_project_id; region = var.gcp_region }
resource "google_project_service" "pubsub" { service = "pubsub.googleapis.com"; disable_on_destroy = false }
resource "google_pubsub_topic" "tick_data"    { name = "topic-${var.project}-tick-data"; message_retention_duration = "604800s"; depends_on = [google_project_service.pubsub] }
resource "google_pubsub_topic" "agent_events" { name = "topic-${var.project}-agent-events"; message_retention_duration = "604800s"; depends_on = [google_project_service.pubsub] }
resource "google_pubsub_topic" "dlq"          { name = "topic-${var.project}-dlq"; depends_on = [google_project_service.pubsub] }
resource "google_pubsub_subscription" "agent_events" {
  name  = "sub-${var.project}-agent-events-backend"
  topic = google_pubsub_topic.agent_events.name
  push_config { push_endpoint = var.backend_url == "" ? "https://placeholder.run.app/events" : "${var.backend_url}/events" }
  ack_deadline_seconds = 30
  dead_letter_policy { dead_letter_topic = google_pubsub_topic.dlq.id; max_delivery_attempts = 5 }
}
output "tick_topic_name"       { value = google_pubsub_topic.tick_data.name }
output "agent_events_topic"    { value = google_pubsub_topic.agent_events.name }
output "dlq_topic_name"        { value = google_pubsub_topic.dlq.name }
