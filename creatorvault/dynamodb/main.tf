terraform {
  required_version = ">= 1.6.0"
  required_providers { aws = { source = "hashicorp/aws", version = "~> 5.0" } }
  backend "s3" { bucket = "terraform-state-rahultech"; key = "creatorvault/dynamodb/terraform.tfstate"; region = "us-east-1"; dynamodb_table = "terraform-state-lock"; encrypt = true }
}
provider "aws" { region = var.aws_region }

resource "aws_dynamodb_table" "main" {
  name         = "${var.project}-${var.env}-data"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "PK"
  range_key    = "SK"

  attribute { name = "PK";     type = "S" }
  attribute { name = "SK";     type = "S" }
  attribute { name = "GSI1PK"; type = "S" }
  attribute { name = "GSI1SK"; type = "S" }

  global_secondary_index { name = "GSI1"; hash_key = "GSI1PK"; range_key = "GSI1SK"; projection_type = "ALL" }
  point_in_time_recovery { enabled = true }
  tags = var.tags
}

output "table_name" { value = aws_dynamodb_table.main.name }
output "table_arn"  { value = aws_dynamodb_table.main.arn }
