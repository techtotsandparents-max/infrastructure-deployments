variable "resource_group_name"   { type = string }
variable "location"               { type = string; default = "centralindia" }
variable "storage_account_name"   { type = string }
variable "replication_type"       { type = string; default = "LRS" }
variable "key_vault_name"         { type = string }
variable "tags"                   { type = map(string); default = {} }
