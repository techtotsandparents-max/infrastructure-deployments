variable "project"       { type = string; default = "creatorvault" }
variable "env"           { type = string; default = "prod" }
variable "aws_region"    { type = string; default = "us-east-1" }
variable "vpc_cidr"      { type = string; default = "10.1.0.0/16" }
variable "public_cidrs"  { type = list(string); default = ["10.1.1.0/24", "10.1.2.0/24"] }
variable "private_cidrs" { type = list(string); default = ["10.1.10.0/24", "10.1.11.0/24"] }
variable "azs"           { type = list(string); default = ["us-east-1a", "us-east-1b"] }
variable "tags"          { type = map(string); default = {} }
