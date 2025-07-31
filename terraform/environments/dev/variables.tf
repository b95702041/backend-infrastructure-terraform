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

# ECS Configuration
variable "ecs_service_name" {
  description = "Name of the ECS service"
  type        = string
  default     = "backend-api"
}

variable "ecs_container_image" {
  description = "Docker image for the application"
  type        = string
  default     = "nginx:latest"  # Default for testing
}

variable "ecs_container_port" {
  description = "Port that the container listens on"
  type        = number
  default     = 80
}

variable "ecs_container_cpu" {
  description = "CPU units for the container (256 = 0.25 vCPU)"
  type        = number
  default     = 256  # Cost-effective for dev
}

variable "ecs_container_memory" {
  description = "Memory in MB for the container"
  type        = number
  default     = 512  # Cost-effective for dev
}

variable "ecs_desired_count" {
  description = "Desired number of running tasks"
  type        = number
  default     = 1  # Single container for dev
}

variable "ecs_enable_load_balancer" {
  description = "Enable Application Load Balancer"
  type        = bool
  default     = true
}

variable "ecs_enable_auto_scaling" {
  description = "Enable auto-scaling for the ECS service"
  type        = bool
  default     = true
}

variable "ecs_health_check_path" {
  description = "Health check path for the load balancer"
  type        = string
  default     = "/"
}

# Jenkins Configuration
variable "jenkins_admin_user" {
  description = "Jenkins admin username"
  type        = string
  default     = "admin"
}

variable "jenkins_admin_password" {
  description = "Jenkins admin password (leave null for auto-generated)"
  type        = string
  default     = null
  sensitive   = true
}

variable "jenkins_cpu" {
  description = "CPU units for Jenkins container (512 = 0.5 vCPU)"
  type        = number
  default     = 512  # Cost-effective for dev
}

variable "jenkins_memory" {
  description = "Memory in MB for Jenkins container"
  type        = number
  default     = 1024  # 1GB for Jenkins
}

variable "jenkins_desired_count" {
  description = "Desired number of Jenkins instances"
  type        = number
  default     = 1
}

variable "jenkins_create_ecr_repository" {
  description = "Create ECR repository for application images"
  type        = bool
  default     = true
}

variable "jenkins_ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = null  # Will use project-environment default
}

variable "jenkins_efs_enabled" {
  description = "Enable EFS storage for Jenkins persistence"
  type        = bool
  default     = false  # Temporarily disable until we fix permissions
}

variable "jenkins_allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access Jenkins"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Internet access for dev
}

variable "jenkins_default_git_repository" {
  description = "Default Git repository URL for Jenkins pipeline"
  type        = string
  default     = ""
}