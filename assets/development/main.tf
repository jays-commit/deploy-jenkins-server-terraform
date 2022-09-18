variable "cidr_block" {}

terraform {

  backend "s3" {
    bucket         = "deploy-jenkins-server-bucket"
    key            = "deploy-jenkins-server/development/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


resource "aws_vpc" "main_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "jenkins-instance-main_vpc"
  }
}

variable "private_subnets_count" {}
variable "public_subnets_count" {}
variable "availability_zones" {}
variable "public_subnets" {}

module "subnet_module" {
  source     = "./modules"
  vpc_id     = aws_vpc.main_vpc.id
  vpc_cidr_block = aws_vpc.main_vpc.cidr_block
  availability_zones = var.availability_zones
  public_subnets_count = var.public_subnets_count
  private_subnets_count = var.private_subnets_count
  public_subnets = var.public_subnets
}