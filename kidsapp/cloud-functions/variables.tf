variable "gcp_project_id"     { type = string }
variable "gcp_region"         { type = string; default = "asia-south1" }
variable "max_instances"      { type = number; default = 10 }
variable "firestore_database" { type = string; default = "" }
