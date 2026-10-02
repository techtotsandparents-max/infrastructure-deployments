terraform {
  required_version = ">= 1.6.0"
  required_providers { aws = { source = "hashicorp/aws", version = "~> 5.0" } }
  backend "s3" {
    bucket         = "terraform-state-rahultech"
    key            = "creatorvault/vpc/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" { region = var.aws_region }

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(var.tags, { Name = "vpc-${var.project}-${var.env}" })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { Name = "igw-${var.project}-${var.env}" })
}

resource "aws_subnet" "public" {
  count                   = length(var.public_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true
  tags = merge(var.tags, { Name = "snet-pub-${count.index}-${var.project}" })
}

resource "aws_subnet" "private" {
  count             = length(var.private_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_cidrs[count.index]
  availability_zone = var.azs[count.index]
  tags = merge(var.tags, { Name = "snet-prv-${count.index}-${var.project}" })
}

resource "aws_eip" "nat"         { domain = "vpc"; tags = merge(var.tags, { Name = "eip-nat-${var.project}" }) }
resource "aws_nat_gateway" "nat" { allocation_id = aws_eip.nat.id; subnet_id = aws_subnet.public[0].id; tags = merge(var.tags, { Name = "nat-${var.project}" }) }

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route { cidr_block = "0.0.0.0/0"; gateway_id = aws_internet_gateway.igw.id }
  tags = merge(var.tags, { Name = "rt-pub-${var.project}" })
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route { cidr_block = "0.0.0.0/0"; nat_gateway_id = aws_nat_gateway.nat.id }
  tags = merge(var.tags, { Name = "rt-prv-${var.project}" })
}

resource "aws_route_table_association" "public"  { count = length(aws_subnet.public);  subnet_id = aws_subnet.public[count.index].id;  route_table_id = aws_route_table.public.id }
resource "aws_route_table_association" "private" { count = length(aws_subnet.private); subnet_id = aws_subnet.private[count.index].id; route_table_id = aws_route_table.private.id }

resource "aws_security_group" "ecs" {
  name   = "sg-ecs-${var.project}-${var.env}"
  vpc_id = aws_vpc.main.id
  egress { from_port = 0; to_port = 0; protocol = "-1"; cidr_blocks = ["0.0.0.0/0"] }
  tags = merge(var.tags, { Name = "sg-ecs-${var.project}" })
}

output "vpc_id"              { value = aws_vpc.main.id }
output "public_subnet_ids"   { value = aws_subnet.public[*].id }
output "private_subnet_ids"  { value = aws_subnet.private[*].id }
output "ecs_security_group_id" { value = aws_security_group.ecs.id }
