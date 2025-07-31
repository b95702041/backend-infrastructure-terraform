# terraform/environments/dev/main.tf
# Main configuration for the development environment

terraform {
  backend "s3" {
    bucket         = "backend-terraform-state-b95702041"
    key            = "environments/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

# Configure the AWS Provider for dev environment
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# Create VPC using our custom module
module "vpc" {
  source = "../../modules/vpc"
  
  project_name            = var.project_name
  environment            = var.environment
  vpc_cidr               = var.vpc_cidr
  availability_zone_count = var.availability_zone_count
}

# Create RDS PostgreSQL database
module "rds" {
  source = "../../modules/rds"
  
  project_name       = var.project_name
  environment        = var.environment
  vpc_id            = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  vpc_cidr_block    = module.vpc.vpc_cidr_block
  
  # Database configuration for dev environment
  db_name           = var.db_name
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  multi_az         = false  # Single AZ for dev to save costs
  deletion_protection = false  # Allow deletion in dev
  skip_final_snapshot = true   # Skip snapshot for dev
}