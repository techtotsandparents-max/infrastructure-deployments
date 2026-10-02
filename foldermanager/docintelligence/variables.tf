variable "resource_group_name"    { type = string }
variable "location"                { type = string; default = "centralindia" }
variable "doc_intelligence_name"   { type = string }
variable "sku_name"                { type = string; default = "F0" }
variable "key_vault_name"          { type = string }
variable "tags"                    { type = map(string); default = {} }
