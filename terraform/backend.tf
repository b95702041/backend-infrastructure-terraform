# terraform/backend.tf
# This file configures where Terraform stores its state file
# State file tracks what resources Terraform has created

terraform {
  backend "s3" {
    # S3 bucket to store the state file
    # You'll need to create this bucket manually first
    bucket = "backend-terraform-state-b95702041"
    
    # Path within the bucket where state files are stored
    # Different environments will have different paths
    key = "infrastructure/terraform.tfstate"
    
    # AWS region where the S3 bucket is located
    region = "us-east-1"
    
    # DynamoDB table for state locking
    # Prevents multiple people from running terraform at the same time
    dynamodb_table = "terraform-state-locks"
    
    # Enable encryption of the state file
    encrypt = true
  }
  
  # Specify minimum Terraform version
  required_version = ">= 1.0"
  
  # Specify required providers and their versions
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  
  # Default tags that will be applied to all resources
  default_tags {
    tags = {
      Project     = "Backend Infrastructure"
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  }
}

# Environment variable - will be defined in each environment folder
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}