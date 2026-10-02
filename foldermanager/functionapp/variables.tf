variable "resource_group_name"          { type = string }
variable "location"                      { type = string; default = "centralindia" }
variable "function_app_name"             { type = string }
variable "func_storage_name"             { type = string }
variable "key_vault_name"                { type = string }
variable "document_storage_account_name" { type = string }
variable "doc_intelligence_endpoint"     { type = string }
variable "openai_endpoint"               { type = string }
variable "search_endpoint"               { type = string }
variable "tags"                          { type = map(string); default = {} }
