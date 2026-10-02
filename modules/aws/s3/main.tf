variable "bucket_name" { type = string }
variable "env" { type = string }
variable "versioning" { type = bool; default = true }
variable "tags" { type = map(string); default = {} }

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  tags   = merge(var.tags, { Environment = var.env })
}

resource "aws_s3_bucket_versioning" "versioning" {
  count  = var.versioning ? 1 : 0
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "pab" {
  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "bucket_id" { value = aws_s3_bucket.bucket.id }
output "bucket_arn" { value = aws_s3_bucket.bucket.arn }
