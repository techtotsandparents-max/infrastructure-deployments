variable "project"          { type = string; default = "creatorvault" }
variable "env"              { type = string; default = "prod" }
variable "aws_region"       { type = string; default = "us-east-1" }
variable "cpu"              { type = number; default = 512 }
variable "memory"           { type = number; default = 1024 }
variable "downloader_image" { type = string; default = "public.ecr.aws/amazonlinux/amazonlinux:2" }
variable "media_bucket_arn" { type = string }
variable "media_bucket_name"{ type = string }
variable "tags"             { type = map(string); default = {} }
