# terraform/environments/dev/variables.tf
# Variables for the development environment

# AWS Configuration
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "backend-infrastructure"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zone_count" {
  description = "Number of availability zones"
  type        = number
  default     = 2
}

# Database Configuration
variable "db_name" {
  description = "Database name"
  type        = string
  default     = "backend_db"
}

variable "db_instance_class" {
  description = "RDS instance class for dev environment"
  type        = string
  default     = "db.t3.micro"  # Free tier eligible
}

variable "db_allocated_storage" {
  description = "Initial allocated storage for RDS"
  type        = number
  default     = 20  # Free tier: up to 20GB
}