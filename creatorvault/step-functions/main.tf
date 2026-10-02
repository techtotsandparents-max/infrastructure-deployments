terraform {
  required_version = ">= 1.6.0"
  required_providers { aws = { source = "hashicorp/aws", version = "~> 5.0" } }
  backend "s3" { bucket = "terraform-state-rahultech"; key = "creatorvault/step-functions/terraform.tfstate"; region = "us-east-1"; dynamodb_table = "terraform-state-lock"; encrypt = true }
}
provider "aws" { region = var.aws_region }

resource "aws_iam_role" "sfn" {
  name = "${var.project}-${var.env}-sfn-exec"
  assume_role_policy = jsonencode({ Version = "2012-10-17"; Statement = [{ Action = "sts:AssumeRole"; Effect = "Allow"; Principal = { Service = "states.amazonaws.com" } }] })
}
resource "aws_iam_role_policy" "sfn" {
  name = "sfn-policy"
  role = aws_iam_role.sfn.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow"; Action = ["lambda:InvokeFunction"]; Resource = [var.submit_lambda_arn, var.chat_lambda_arn, var.status_lambda_arn] },
      { Effect = "Allow"; Action = ["ecs:RunTask","ecs:StopTask","ecs:DescribeTasks","iam:PassRole"]; Resource = "*" },
      { Effect = "Allow"; Action = ["transcribe:StartTranscriptionJob","transcribe:GetTranscriptionJob"]; Resource = "*" },
      { Effect = "Allow"; Action = ["bedrock:InvokeModel"]; Resource = "*" },
      { Effect = "Allow"; Action = ["dynamodb:PutItem","dynamodb:UpdateItem","dynamodb:GetItem"]; Resource = var.dynamodb_table_arn },
      { Effect = "Allow"; Action = ["s3:GetObject","s3:PutObject"]; Resource = "${var.media_bucket_arn}/*" },
      { Effect = "Allow"; Action = ["logs:*"]; Resource = "*" }
    ]
  })
}

resource "aws_sfn_state_machine" "video_processor" {
  name     = "${var.project}-${var.env}-video-processor"
  role_arn = aws_iam_role.sfn.arn
  type     = "STANDARD"
  definition = jsonencode({
    Comment = "Creator Vault — Video Processing Pipeline"
    StartAt = "ValidateURL"
    States = {
      ValidateURL = { Type = "Task"; Resource = "arn:aws:states:::lambda:invoke"; Parameters = { FunctionName = var.submit_lambda_arn; "Payload.$" = "$" }; ResultPath = "$.validation"; Next = "DownloadVideo" }
      DownloadVideo = { Type = "Task"; Resource = "arn:aws:states:::ecs:runTask.sync"; Parameters = { LaunchType = "FARGATE"; Cluster = var.ecs_cluster_arn; TaskDefinition = var.ecs_task_def_arn; NetworkConfiguration = { AwsvpcConfiguration = { "Subnets.$" = "States.Array('placeholder')"; AssignPublicIp = "DISABLED" } } }; ResultPath = "$.download"; Next = "Transcribe" }
      Transcribe = { Type = "Task"; Resource = "arn:aws:states:::aws-sdk:transcribe:startTranscriptionJob"; Parameters = { TranscriptionJobName = "States.Format('cv-{}', $.jobId)"; LanguageCode = "en-US"; Media = { "MediaFileUri.$" = "States.Format('s3://${var.media_bucket_name}/raw/{}/audio.mp3', $.jobId)" }; OutputBucketName = var.media_bucket_name }; ResultPath = "$.transcription"; Next = "WaitForTranscription" }
      WaitForTranscription = { Type = "Wait"; Seconds = 30; Next = "Summarize" }
      Summarize = { Type = "Task"; Resource = "arn:aws:states:::bedrock:invokeModel"; Parameters = { ModelId = "anthropic.claude-3-5-sonnet-20241022-v2:0"; ContentType = "application/json"; Body = { "prompt.$" = "$.transcription" } }; ResultPath = "$.summary"; Next = "StoreResults" }
      StoreResults = { Type = "Task"; Resource = "arn:aws:states:::dynamodb:putItem"; Parameters = { TableName = var.dynamodb_table_name; Item = { PK = { "S.$" = "States.Format('JOB#{}', $.jobId)" }; SK = { S = "RESULT" }; status = { S = "COMPLETED" } } }; End = true }
    }
  })
  tags = var.tags
}

output "state_machine_arn"  { value = aws_sfn_state_machine.video_processor.arn }
output "state_machine_name" { value = aws_sfn_state_machine.video_processor.name }
