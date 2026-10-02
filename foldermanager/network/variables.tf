variable "resource_group_name" { type = string }
variable "location"            { type = string; default = "centralindia" }
variable "vnet_name"           { type = string }
variable "vnet_address_space"  { type = string; default = "10.10.0.0/16" }
variable "subnet_app_prefix"   { type = string; default = "10.10.1.0/24" }
variable "subnet_endpoints_prefix" { type = string; default = "10.10.2.0/24" }
variable "tags"                { type = map(string); default = {} }
