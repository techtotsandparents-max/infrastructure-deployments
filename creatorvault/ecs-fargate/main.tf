terraform {
  required_version = ">= 1.6.0"
  required_providers { aws = { source = "hashicorp/aws", version = "~> 5.0" } }
  backend "s3" { bucket = "terraform-state-rahultech"; key = "creatorvault/ecs-fargate/terraform.tfstate"; region = "us-east-1"; dynamodb_table = "terraform-state-lock"; encrypt = true }
}
provider "aws" { region = var.aws_region }

resource "aws_ecs_cluster" "main" {
  name = "${var.project}-${var.env}-cluster"
  setting { name = "containerInsights"; value = "enabled" }
  tags = var.tags
}

resource "aws_cloudwatch_log_group" "ecs" { name = "/ecs/${var.project}-${var.env}"; retention_in_days = 14 }

resource "aws_iam_role" "ecs_exec" {
  name = "${var.project}-${var.env}-ecs-exec"
  assume_role_policy = jsonencode({ Version = "2012-10-17"; Statement = [{ Action = "sts:AssumeRole"; Effect = "Allow"; Principal = { Service = "ecs-tasks.amazonaws.com" } }] })
}
resource "aws_iam_role_policy_attachment" "ecs_exec" { role = aws_iam_role.ecs_exec.name; policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy" }

resource "aws_iam_role" "ecs_task" {
  name = "${var.project}-${var.env}-ecs-task"
  assume_role_policy = jsonencode({ Version = "2012-10-17"; Statement = [{ Action = "sts:AssumeRole"; Effect = "Allow"; Principal = { Service = "ecs-tasks.amazonaws.com" } }] })
}
resource "aws_iam_role_policy" "ecs_s3" {
  name = "s3-access"
  role = aws_iam_role.ecs_task.id
  policy = jsonencode({ Version = "2012-10-17"; Statement = [{ Effect = "Allow"; Action = ["s3:PutObject","s3:GetObject"]; Resource = ["${var.media_bucket_arn}/*"] }] })
}

resource "aws_ecs_task_definition" "downloader" {
  family                   = "${var.project}-${var.env}-downloader"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_exec.arn
  task_role_arn            = aws_iam_role.ecs_task.arn
  container_definitions = jsonencode([{
    name      = "downloader"
    image     = var.downloader_image
    essential = true
    environment = [{ name = "MEDIA_BUCKET"; value = var.media_bucket_name }]
    logConfiguration = { logDriver = "awslogs"; options = { "awslogs-group" = aws_cloudwatch_log_group.ecs.name; "awslogs-region" = var.aws_region; "awslogs-stream-prefix" = "downloader" } }
  }])
  tags = var.tags
}

output "cluster_arn"          { value = aws_ecs_cluster.main.arn }
output "task_definition_arn"  { value = aws_ecs_task_definition.downloader.arn }
output "ecs_exec_role_arn"    { value = aws_iam_role.ecs_exec.arn }
output "ecs_task_role_arn"    { value = aws_iam_role.ecs_task.arn }
