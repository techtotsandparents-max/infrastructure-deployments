variable "project"               { type = string; default = "creatorvault" }
variable "env"                   { type = string; default = "prod" }
variable "aws_region"            { type = string; default = "us-east-1" }
variable "frontend_bucket_id"    { type = string }
variable "frontend_bucket_arn"   { type = string }
variable "frontend_bucket_domain"{ type = string }
variable "api_endpoint"          { type = string }
variable "tags"                  { type = map(string); default = {} }
