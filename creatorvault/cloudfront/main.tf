terraform {
  required_version = ">= 1.6.0"
  required_providers { aws = { source = "hashicorp/aws", version = "~> 5.0" } }
  backend "s3" { bucket = "terraform-state-rahultech"; key = "creatorvault/cloudfront/terraform.tfstate"; region = "us-east-1"; dynamodb_table = "terraform-state-lock"; encrypt = true }
}
provider "aws" { region = var.aws_region }

resource "aws_cloudfront_origin_access_identity" "oai" { comment = "${var.project}-${var.env} Frontend OAI" }

resource "aws_s3_bucket_policy" "frontend" {
  bucket = var.frontend_bucket_id
  policy = jsonencode({ Version = "2012-10-17"; Statement = [{ Sid = "OAI"; Effect = "Allow"; Principal = { AWS = aws_cloudfront_origin_access_identity.oai.iam_arn }; Action = "s3:GetObject"; Resource = "${var.frontend_bucket_arn}/*" }] })
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"
  comment             = "${var.project}-${var.env}"
  tags                = var.tags

  origin { domain_name = var.frontend_bucket_domain; origin_id = "s3-frontend"; s3_origin_config { origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path } }
  origin { domain_name = replace(var.api_endpoint, "https://", ""); origin_id = "api-gw"; custom_origin_config { http_port = 80; https_port = 443; origin_protocol_policy = "https-only"; origin_ssl_protocols = ["TLSv1.2"] } }

  default_cache_behavior {
    allowed_methods  = ["GET","HEAD","OPTIONS"]
    cached_methods   = ["GET","HEAD"]
    target_origin_id = "s3-frontend"
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values { query_string = false; cookies { forward = "none" } }
    compress = true
  }

  ordered_cache_behavior {
    path_pattern     = "/api/*"
    allowed_methods  = ["DELETE","GET","HEAD","OPTIONS","PATCH","POST","PUT"]
    cached_methods   = ["GET","HEAD"]
    target_origin_id = "api-gw"
    viewer_protocol_policy = "https-only"
    forwarded_values { query_string = true; headers = ["Authorization","Origin"]; cookies { forward = "none" } }
    min_ttl = 0; default_ttl = 0; max_ttl = 0
  }

  custom_error_response { error_code = 404; response_code = 200; response_page_path = "/index.html" }
  custom_error_response { error_code = 403; response_code = 200; response_page_path = "/index.html" }
  restrictions { geo_restriction { restriction_type = "none" } }
  viewer_certificate { cloudfront_default_certificate = true }
}

output "cloudfront_domain"          { value = aws_cloudfront_distribution.cdn.domain_name }
output "cloudfront_distribution_id" { value = aws_cloudfront_distribution.cdn.id }
