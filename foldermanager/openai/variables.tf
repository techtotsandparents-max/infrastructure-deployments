variable "resource_group_name"  { type = string }
variable "openai_account_name"  { type = string }
variable "key_vault_name"       { type = string }
variable "gpt_capacity"         { type = number; default = 10 }
variable "embedding_capacity"   { type = number; default = 10 }
variable "tags"                 { type = map(string); default = {} }
