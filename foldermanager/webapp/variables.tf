variable "resource_group_name"     { type = string }
variable "location"                 { type = string; default = "centralindia" }
variable "virtual_network_name"     { type = string }
variable "subnet_integration_name"  { type = string; default = "snet-app" }
variable "app_service_plan_name"    { type = string }
variable "webapp_name"              { type = string }
variable "node_version"             { type = string; default = "20-lts" }
variable "sku_name"                 { type = string; default = "B1" }
variable "key_vault_name"           { type = string }
variable "tags"                     { type = map(string); default = {} }
