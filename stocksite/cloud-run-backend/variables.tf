variable "gcp_project_id"   { type = string }
variable "gcp_region"       { type = string; default = "asia-south1" }
variable "project"          { type = string; default = "stocksite" }
variable "env"              { type = string; default = "prod" }
variable "backend_image"    { type = string; default = "gcr.io/cloudrun/placeholder" }
variable "cpu"              { type = string; default = "1" }
variable "memory"           { type = string; default = "1Gi" }
variable "max_instances"    { type = number; default = 5 }
variable "vpc_connector_id" { type = string; default = "" }
variable "firestore_db"     { type = string; default = "" }
variable "bq_dataset"       { type = string; default = "market_data" }
variable "pubsub_tick_topic"{ type = string; default = "" }
variable "labels"           { type = map(string); default = {} }
