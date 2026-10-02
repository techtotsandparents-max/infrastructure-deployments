variable "gcp_project_id"   { type = string }
variable "gcp_region"       { type = string; default = "asia-south1" }
variable "project"          { type = string; default = "stocksite" }
variable "env"              { type = string; default = "prod" }
variable "frontend_image"   { type = string; default = "gcr.io/cloudrun/placeholder" }
variable "backend_url"      { type = string; default = "" }
variable "cpu"              { type = string; default = "1" }
variable "memory"           { type = string; default = "512Mi" }
variable "max_instances"    { type = number; default = 3 }
variable "vpc_connector_id" { type = string; default = "" }
variable "labels"           { type = map(string); default = {} }
