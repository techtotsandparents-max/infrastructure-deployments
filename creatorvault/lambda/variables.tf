variable "project"            { type = string; default = "creatorvault" }
variable "env"                { type = string; default = "prod" }
variable "aws_region"         { type = string; default = "us-east-1" }
variable "dynamodb_table_arn" { type = string }
variable "dynamodb_table_name"{ type = string }
variable "media_bucket_arn"   { type = string }
variable "media_bucket_name"  { type = string }
variable "state_machine_arn"  { type = string; default = "" }
variable "tags"               { type = map(string); default = {} }
