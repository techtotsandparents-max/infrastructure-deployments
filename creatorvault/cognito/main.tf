terraform {
  required_version = ">= 1.6.0"
  required_providers { aws = { source = "hashicorp/aws", version = "~> 5.0" } }
  backend "s3" { bucket = "terraform-state-rahultech"; key = "creatorvault/cognito/terraform.tfstate"; region = "us-east-1"; dynamodb_table = "terraform-state-lock"; encrypt = true }
}
provider "aws" { region = var.aws_region }

resource "aws_cognito_user_pool" "pool" {
  name = "${var.project}-${var.env}-users"
  auto_verified_attributes = ["email"]
  username_attributes       = ["email"]
  password_policy { minimum_length = 8; require_lowercase = true; require_uppercase = true; require_numbers = true; require_symbols = false }
  schema { attribute_data_type = "String"; name = "email"; required = true; mutable = true; string_attribute_constraints { min_length = 1; max_length = 256 } }
  account_recovery_setting { recovery_mechanism { name = "verified_email"; priority = 1 } }
  tags = var.tags
}

resource "aws_cognito_user_pool_client" "spa" {
  name                                 = "${var.project}-${var.env}-spa"
  user_pool_id                         = aws_cognito_user_pool.pool.id
  generate_secret                      = false
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  callback_urls                        = var.callback_urls
  logout_urls                          = var.logout_urls
  supported_identity_providers         = ["COGNITO"]
  explicit_auth_flows                  = ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
}

resource "aws_cognito_user_pool_domain" "domain" {
  domain       = "${var.project}-${var.env}"
  user_pool_id = aws_cognito_user_pool.pool.id
}

output "user_pool_id"  { value = aws_cognito_user_pool.pool.id }
output "client_id"     { value = aws_cognito_user_pool_client.spa.id }
output "issuer_url"    { value = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.pool.id}" }
output "hosted_ui_url" { value = "https://${aws_cognito_user_pool_domain.domain.domain}.auth.${var.aws_region}.amazoncognito.com" }
