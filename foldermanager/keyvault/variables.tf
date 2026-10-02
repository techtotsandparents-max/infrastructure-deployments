variable "resource_group_name" { type = string }
variable "location"            { type = string; default = "centralindia" }
variable "key_vault_name"      { type = string }
variable "tags"                { type = map(string); default = {} }
