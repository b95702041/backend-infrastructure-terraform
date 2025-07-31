# terraform/modules/jenkins/variables.tf
# Input variables for the Jenkins module

variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where Jenkins will be deployed"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for Jenkins Application Load Balancer"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for Jenkins ECS tasks"
  type        = list(string)
}

variable "vpc_cidr_block" {
  description = "CIDR block of the VPC for security group rules"
  type        = string
}

# ECS Cluster Integration
variable "ecs_cluster_id" {
  description = "ID of the existing ECS cluster where Jenkins will deploy applications"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the existing ECS cluster"
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the ECS service that Jenkins will deploy to"
  type        = string
  default     = "backend-api"
}

# Database Integration (for application deployments)
variable "db_endpoint" {
  description = "RDS database endpoint for application deployments"
  type        = string
}

variable "secrets_manager_secret_arn" {
  description = "ARN of the Secrets Manager secret containing database credentials"
  type        = string
}

# Jenkins Configuration
variable "jenkins_admin_user" {
  description = "Jenkins admin username"
  type        = string
  default     = "admin"
}

variable "jenkins_admin_password" {
  description = "Jenkins admin password (will be stored in Secrets Manager)"
  type        = string
  default     = null  # Will generate random password if not provided
}

variable "jenkins_container_image" {
  description = "Jenkins Docker image"
  type        = string
  default     = "jenkins/jenkins:lts-jdk11"
}

variable "jenkins_container_port" {
  description = "Port that Jenkins container listens on"
  type        = number
  default     = 8080
}

variable "jenkins_cpu" {
  description = "CPU units for Jenkins container (1024 = 1 vCPU)"
  type        = number
  default     = 512  # 0.5 vCPU for dev
}

variable "jenkins_memory" {
  description = "Memory in MB for Jenkins container"
  type        = number
  default     = 1024  # 1GB for Jenkins
}

variable "jenkins_desired_count" {
  description = "Desired number of Jenkins instances"
  type        = number
  default     = 1  # Single instance for dev
}

# Container Registry Configuration
variable "create_ecr_repository" {
  description = "Create ECR repository for storing application Docker images"
  type        = bool
  default     = true
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = null  # Will default to project-name-environment if not provided
}

variable "ecr_image_tag_mutability" {
  description = "The tag mutability setting for the repository"
  type        = string
  default     = "MUTABLE"
  
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.ecr_image_tag_mutability)
    error_message = "ECR image tag mutability must be either MUTABLE or IMMUTABLE."
  }
}

variable "ecr_scan_on_push" {
  description = "Enable image scanning on push to ECR"
  type        = bool
  default     = true
}

# Load Balancer Configuration
variable "jenkins_health_check_path" {
  description = "Health check path for Jenkins"
  type        = string
  default     = "/login"
}

variable "jenkins_health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 10
}

variable "jenkins_health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "healthy_threshold" {
  description = "Number of consecutive successful health checks"
  type        = number
  default     = 2
}

variable "unhealthy_threshold" {
  description = "Number of consecutive failed health checks"
  type        = number
  default     = 3
}

# Storage Configuration
variable "jenkins_efs_enabled" {
  description = "Enable EFS storage for Jenkins persistence"
  type        = bool
  default     = true
}

variable "jenkins_efs_throughput_mode" {
  description = "EFS throughput mode"
  type        = string
  default     = "bursting"
  
  validation {
    condition     = contains(["bursting", "provisioned"], var.jenkins_efs_throughput_mode)
    error_message = "EFS throughput mode must be either 'bursting' or 'provisioned'."
  }
}

variable "jenkins_efs_performance_mode" {
  description = "EFS performance mode"
  type        = string
  default     = "generalPurpose"
  
  validation {
    condition     = contains(["generalPurpose", "maxIO"], var.jenkins_efs_performance_mode)
    error_message = "EFS performance mode must be either 'generalPurpose' or 'maxIO'."
  }
}

# Pipeline Configuration
variable "default_git_repository" {
  description = "Default Git repository URL for Jenkins pipeline"
  type        = string
  default     = ""
}

variable "git_credentials_secret_arn" {
  description = "ARN of Secrets Manager secret containing Git credentials (optional)"
  type        = string
  default     = ""
}

# Security Configuration
variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access Jenkins (empty list means VPC-only access)"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Internet access for dev, restrict for production
}

variable "enable_jenkins_csrf_protection" {
  description = "Enable CSRF protection in Jenkins"
  type        = bool
  default     = true
}

# Environment Variables for Jenkins
variable "jenkins_environment_variables" {
  description = "Additional environment variables for Jenkins container"
  type        = map(string)
  default = {
    JAVA_OPTS = "-Djenkins.install.runSetupWizard=false"
  }
}