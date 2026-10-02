variable "project"    { type = string; default = "creatorvault" }
variable "env"        { type = string; default = "prod" }
variable "aws_region" { type = string; default = "us-east-1" }
variable "tags"       { type = map(string); default = {} }
