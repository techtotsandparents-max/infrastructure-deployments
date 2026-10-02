terraform {
  required_version = ">= 1.6.0"
  required_providers { google = { source = "hashicorp/google", version = "~> 6.0" }; google-beta = { source = "hashicorp/google-beta", version = "~> 6.0" } }
  backend "gcs" { bucket = "terraform-state-rahultech-gcp"; prefix = "kidsapp/firebase" }
}
provider "google"      { project = var.gcp_project_id; region = var.gcp_region }
provider "google-beta" { project = var.gcp_project_id; region = var.gcp_region }

resource "google_project_service" "firebase" { service = "firebase.googleapis.com"; disable_on_destroy = false }
resource "google_firebase_project" "main"    { provider = google-beta; project = var.gcp_project_id; depends_on = [google_project_service.firebase] }
resource "google_firebase_web_app" "web"     { provider = google-beta; project = var.gcp_project_id; display_name = "${var.display_name} - Web"; depends_on = [google_firebase_project.main] }
resource "google_firebase_android_app" "app" { provider = google-beta; project = var.gcp_project_id; display_name = "${var.display_name} - Android"; package_name = var.android_package; depends_on = [google_firebase_project.main] }
resource "google_firebase_apple_app" "ios"   { provider = google-beta; project = var.gcp_project_id; display_name = "${var.display_name} - iOS"; bundle_id = var.ios_bundle_id; depends_on = [google_firebase_project.main] }
output "firebase_project"  { value = google_firebase_project.main.project }
output "web_app_id"         { value = google_firebase_web_app.web.app_id }
output "android_app_id"     { value = google_firebase_android_app.app.app_id }
output "ios_app_id"         { value = google_firebase_apple_app.ios.app_id }
