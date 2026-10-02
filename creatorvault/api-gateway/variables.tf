variable "project"             { type = string; default = "creatorvault" }
variable "env"                 { type = string; default = "prod" }
variable "aws_region"          { type = string; default = "us-east-1" }
variable "cors_origins"        { type = list(string); default = ["http://localhost:5173"] }
variable "cognito_client_id"   { type = string }
variable "cognito_issuer_url"  { type = string }
variable "submit_lambda_arn"   { type = string }
variable "status_lambda_arn"   { type = string }
variable "chat_lambda_arn"     { type = string }
variable "tags"                { type = map(string); default = {} }
