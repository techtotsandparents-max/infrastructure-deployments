terraform {
  required_version = ">= 1.6.0"
  required_providers { aws = { source = "hashicorp/aws", version = "~> 5.0" } }
  backend "s3" { bucket = "terraform-state-rahultech"; key = "creatorvault/api-gateway/terraform.tfstate"; region = "us-east-1"; dynamodb_table = "terraform-state-lock"; encrypt = true }
}
provider "aws" { region = var.aws_region }

resource "aws_apigatewayv2_api" "api" {
  name          = "${var.project}-${var.env}-api"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = var.cors_origins
    allow_methods = ["GET","POST","PUT","DELETE","OPTIONS"]
    allow_headers = ["Content-Type","Authorization"]
    max_age       = 3600
  }
  tags = var.tags
}

resource "aws_cloudwatch_log_group" "api" { name = "/aws/apigateway/${var.project}-${var.env}"; retention_in_days = 14 }

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
  access_log_settings { destination_arn = aws_cloudwatch_log_group.api.arn; format = jsonencode({ requestId = "$context.requestId"; status = "$context.status"; httpMethod = "$context.httpMethod"; routeKey = "$context.routeKey" }) }
}

resource "aws_apigatewayv2_authorizer" "cognito" {
  api_id           = aws_apigatewayv2_api.api.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "${var.project}-cognito-auth"
  jwt_configuration {
    audience = [var.cognito_client_id]
    issuer   = var.cognito_issuer_url
  }
}

locals {
  routes = {
    "POST /api/submit"        = var.submit_lambda_arn
    "GET /api/jobs/{jobId}"   = var.status_lambda_arn
    "POST /api/chat"          = var.chat_lambda_arn
  }
}

resource "aws_apigatewayv2_integration" "lambda" {
  for_each               = local.routes
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = each.value
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "routes" {
  for_each           = local.routes
  api_id             = aws_apigatewayv2_api.api.id
  route_key          = each.key
  target             = "integrations/${aws_apigatewayv2_integration.lambda[each.key].id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}

output "api_endpoint" { value = aws_apigatewayv2_api.api.api_endpoint }
output "api_id"       { value = aws_apigatewayv2_api.api.id }
output "execution_arn"{ value = aws_apigatewayv2_api.api.execution_arn }
