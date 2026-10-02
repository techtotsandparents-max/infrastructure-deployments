terraform {
  required_version = ">= 1.6.0"
  required_providers { google = { source = "hashicorp/google", version = "~> 6.0" } }
  backend "gcs" { bucket = "terraform-state-rahultech-gcp"; prefix = "stocksite/bigquery" }
}
provider "google" { project = var.gcp_project_id; region = var.gcp_region }
resource "google_project_service" "bq" { service = "bigquery.googleapis.com"; disable_on_destroy = false }
resource "google_bigquery_dataset" "market_data" { dataset_id = var.dataset_id; location = var.gcp_region; description = "Stock Site — market data + trade signals"; delete_contents_on_destroy = false; depends_on = [google_project_service.bq] }
resource "google_bigquery_table" "tick_data" { dataset_id = google_bigquery_dataset.market_data.dataset_id; table_id = "tick_data"; deletion_protection = false
  time_partitioning { type = "DAY"; field = "timestamp" }
  schema = jsonencode([{ name = "symbol"; type = "STRING"; mode = "REQUIRED" },{ name = "timestamp"; type = "TIMESTAMP"; mode = "REQUIRED" },{ name = "price"; type = "FLOAT64"; mode = "REQUIRED" },{ name = "volume"; type = "INT64"; mode = "REQUIRED" }])
}
resource "google_bigquery_table" "trade_signals" { dataset_id = google_bigquery_dataset.market_data.dataset_id; table_id = "trade_signals"; deletion_protection = false
  time_partitioning { type = "DAY"; field = "generated_at" }
  schema = jsonencode([{ name = "signal_id"; type = "STRING"; mode = "REQUIRED" },{ name = "symbol"; type = "STRING"; mode = "REQUIRED" },{ name = "signal_type"; type = "STRING" },{ name = "confidence"; type = "FLOAT64" },{ name = "agent_id"; type = "STRING" },{ name = "generated_at"; type = "TIMESTAMP"; mode = "REQUIRED" }])
}
output "dataset_id"          { value = google_bigquery_dataset.market_data.dataset_id }
output "tick_table_id"       { value = google_bigquery_table.tick_data.table_id }
output "signals_table_id"    { value = google_bigquery_table.trade_signals.table_id }
