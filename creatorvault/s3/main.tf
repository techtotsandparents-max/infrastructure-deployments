terraform {
  required_version = ">= 1.6.0"
  required_providers { aws = { source = "hashicorp/aws", version = "~> 5.0" } }
  backend "s3" { bucket = "terraform-state-rahultech"; key = "creatorvault/s3/terraform.tfstate"; region = "us-east-1"; dynamodb_table = "terraform-state-lock"; encrypt = true }
}
provider "aws" { region = var.aws_region }

resource "aws_s3_bucket" "media" {
  bucket = "${var.project}-${var.env}-media"
  tags   = merge(var.tags, { Name = "${var.project}-media" })
}
resource "aws_s3_bucket_versioning" "media"              { bucket = aws_s3_bucket.media.id; versioning_configuration { status = "Enabled" } }
resource "aws_s3_bucket_server_side_encryption_configuration" "media" { bucket = aws_s3_bucket.media.id; rule { apply_server_side_encryption_by_default { sse_algorithm = "AES256" } } }
resource "aws_s3_bucket_public_access_block" "media"    { bucket = aws_s3_bucket.media.id; block_public_acls = true; block_public_policy = true; ignore_public_acls = true; restrict_public_buckets = true }
resource "aws_s3_bucket_lifecycle_configuration" "media" {
  bucket = aws_s3_bucket.media.id
  rule { id = "archive-raw"; status = "Enabled"; filter { prefix = "raw/" }; transition { days = 30; storage_class = "GLACIER_IR" } }
  rule { id = "cleanup-temp"; status = "Enabled"; filter { prefix = "temp/" }; expiration { days = 7 } }
}

resource "aws_s3_bucket" "frontend" {
  bucket = "${var.project}-${var.env}-frontend"
  tags   = merge(var.tags, { Name = "${var.project}-frontend" })
}
resource "aws_s3_bucket_public_access_block" "frontend" { bucket = aws_s3_bucket.frontend.id; block_public_acls = true; block_public_policy = true; ignore_public_acls = true; restrict_public_buckets = true }

output "media_bucket_id"    { value = aws_s3_bucket.media.id }
output "media_bucket_arn"   { value = aws_s3_bucket.media.arn }
output "frontend_bucket_id" { value = aws_s3_bucket.frontend.id }
output "frontend_bucket_arn"{ value = aws_s3_bucket.frontend.arn }
output "frontend_bucket_domain" { value = aws_s3_bucket.frontend.bucket_regional_domain_name }
