variable "gcp_project_id" { type = string }
variable "gcp_region"     { type = string; default = "asia-south1" }
variable "project"        { type = string; default = "stocksite" }
variable "env"            { type = string; default = "prod" }
variable "subnet_cidr"    { type = string; default = "10.2.0.0/20" }
variable "connector_cidr" { type = string; default = "10.2.64.0/28" }
