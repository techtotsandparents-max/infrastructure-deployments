variable "project"       { type = string; default = "creatorvault" }
variable "env"           { type = string; default = "prod" }
variable "aws_region"    { type = string; default = "us-east-1" }
variable "callback_urls" { type = list(string); default = ["http://localhost:5173/callback"] }
variable "logout_urls"   { type = list(string); default = ["http://localhost:5173"] }
variable "tags"          { type = map(string); default = {} }
