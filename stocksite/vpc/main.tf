terraform {
  required_version = ">= 1.6.0"
  required_providers { google = { source = "hashicorp/google", version = "~> 6.0" } }
  backend "gcs" { bucket = "terraform-state-rahultech-gcp"; prefix = "stocksite/vpc" }
}
provider "google" { project = var.gcp_project_id; region = var.gcp_region }

resource "google_project_service" "apis" {
  for_each = toset(["compute.googleapis.com","vpcaccess.googleapis.com","servicenetworking.googleapis.com"])
  service  = each.value; disable_on_destroy = false
}
resource "google_compute_network" "vpc"    { name = "vpc-${var.project}-${var.env}"; auto_create_subnetworks = false; depends_on = [google_project_service.apis] }
resource "google_compute_subnetwork" "main"{ name = "snet-${var.project}-${var.env}"; ip_cidr_range = var.subnet_cidr; region = var.gcp_region; network = google_compute_network.vpc.id; private_ip_google_access = true }
resource "google_compute_firewall" "allow_internal" { name = "fw-allow-internal-${var.project}"; network = google_compute_network.vpc.name; allow { protocol = "tcp"; ports = ["0-65535"] }; source_ranges = [var.subnet_cidr] }
resource "google_vpc_access_connector" "connector" { name = "vpcconn-${var.project}"; region = var.gcp_region; ip_cidr_range = var.connector_cidr; network = google_compute_network.vpc.name; depends_on = [google_project_service.apis] }

output "vpc_name"        { value = google_compute_network.vpc.name }
output "subnet_name"     { value = google_compute_subnetwork.main.name }
output "connector_name"  { value = google_vpc_access_connector.connector.name }
output "connector_id"    { value = google_vpc_access_connector.connector.id }
