terraform {
  required_version = ">= 1.6.0"
  required_providers { aws = { source = "hashicorp/aws", version = "~> 5.0" } }
  backend "s3" { bucket = "terraform-state-rahultech"; key = "creatorvault/lambda/terraform.tfstate"; region = "us-east-1"; dynamodb_table = "terraform-state-lock"; encrypt = true }
}
provider "aws" { region = var.aws_region }

resource "aws_iam_role" "lambda_exec" {
  name = "${var.project}-${var.env}-lambda-exec"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole"; Effect = "Allow"; Principal = { Service = "lambda.amazonaws.com" } }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.project}-${var.env}-lambda-policy"
  role = aws_iam_role.lambda_exec.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow"; Action = ["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents"]; Resource = "arn:aws:logs:*:*:*" },
      { Effect = "Allow"; Action = ["dynamodb:GetItem","dynamodb:PutItem","dynamodb:UpdateItem","dynamodb:Query","dynamodb:Scan"]; Resource = [var.dynamodb_table_arn,"${var.dynamodb_table_arn}/index/*"] },
      { Effect = "Allow"; Action = ["s3:GetObject","s3:PutObject","s3:ListBucket"]; Resource = [var.media_bucket_arn,"${var.media_bucket_arn}/*"] },
      { Effect = "Allow"; Action = ["bedrock:InvokeModel","bedrock:InvokeModelWithResponseStream"]; Resource = "*" },
      { Effect = "Allow"; Action = ["transcribe:StartTranscriptionJob","transcribe:GetTranscriptionJob"]; Resource = "*" },
      { Effect = "Allow"; Action = ["states:StartExecution"]; Resource = var.state_machine_arn }
    ]
  })
}

data "archive_file" "placeholder" { type = "zip"; output_path = "${path.module}/placeholder.zip"; source { content = "# placeholder"; filename = "handler.py" } }

locals {
  functions = {
    submit-url    = { handler = "handler.submit_url"; memory = 256; timeout = 30 }
    job-status    = { handler = "handler.job_status";  memory = 256; timeout = 30 }
    chat-handler  = { handler = "handler.chat";        memory = 512; timeout = 60 }
  }
}

resource "aws_lambda_function" "fn" {
  for_each      = local.functions
  function_name = "${var.project}-${var.env}-${each.key}"
  runtime       = "python3.12"
  handler       = each.value.handler
  role          = aws_iam_role.lambda_exec.arn
  memory_size   = each.value.memory
  timeout       = each.value.timeout
  filename      = data.archive_file.placeholder.output_path

  environment {
    variables = {
      TABLE_NAME    = var.dynamodb_table_name
      MEDIA_BUCKET  = var.media_bucket_name
      STATE_MACHINE = var.state_machine_arn
      ENVIRONMENT   = var.env
      BEDROCK_MODEL = "anthropic.claude-3-5-sonnet-20241022-v2:0"
    }
  }
  tags = merge(var.tags, { Function = each.key })
  lifecycle { ignore_changes = [filename, source_code_hash] }
}

output "submit_url_arn"   { value = aws_lambda_function.fn["submit-url"].arn }
output "job_status_arn"   { value = aws_lambda_function.fn["job-status"].arn }
output "chat_handler_arn" { value = aws_lambda_function.fn["chat-handler"].arn }
output "lambda_role_arn"  { value = aws_iam_role.lambda_exec.arn }
