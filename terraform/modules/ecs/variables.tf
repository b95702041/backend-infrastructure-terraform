# terraform/modules/ecs/variables.tf
# Input variables for the ECS module

variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where ECS will be deployed"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for Application Load Balancer"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "vpc_cidr_block" {
  description = "CIDR block of the VPC for security group rules"
  type        = string
}

# Database Integration
variable "db_endpoint" {
  description = "RDS database endpoint for application connection"
  type        = string
}

variable "db_port" {
  description = "RDS database port"
  type        = number
  default     = 5432
}

variable "db_security_group_id" {
  description = "Security group ID of the RDS database"
  type        = string
}

variable "secrets_manager_secret_arn" {
  description = "ARN of the Secrets Manager secret containing database credentials"
  type        = string
}

# ECS Configuration
variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = null # Will default to "${project_name}-${environment}-cluster"
}

variable "service_name" {
  description = "Name of the ECS service"
  type        = string
  default     = "backend-api"
}

variable "container_name" {
  description = "Name of the container"
  type        = string
  default     = "app"
}

variable "container_image" {
  description = "Docker image for the application container"
  type        = string
  default     = "nginx:latest" # Default to nginx for testing
}

variable "container_port" {
  description = "Port that the container listens on"
  type        = number
  default     = 80
}

variable "container_cpu" {
  description = "CPU units for the container (1024 = 1 vCPU)"
  type        = number
  default     = 256 # 0.25 vCPU - cost-effective for dev
}

variable "container_memory" {
  description = "Memory in MB for the container"
  type        = number
  default     = 512 # 512 MB - cost-effective for dev
}

variable "desired_count" {
  description = "Desired number of running tasks"
  type        = number
  default     = 1 # Single instance for dev
}

variable "max_capacity" {
  description = "Maximum number of tasks for auto-scaling"
  type        = number
  default     = 3
}

variable "min_capacity" {
  description = "Minimum number of tasks for auto-scaling"
  type        = number
  default     = 1
}

# Load Balancer Configuration
variable "enable_load_balancer" {
  description = "Enable Application Load Balancer"
  type        = bool
  default     = true
}

variable "health_check_path" {
  description = "Health check path for the load balancer"
  type        = string
  default     = "/"
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "health_check_interval" {
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

# Auto Scaling Configuration
variable "enable_auto_scaling" {
  description = "Enable auto-scaling for the ECS service"
  type        = bool
  default     = true
}

variable "cpu_target_value" {
  description = "Target CPU utilization percentage for auto-scaling"
  type        = number
  default     = 70
}

variable "memory_target_value" {
  description = "Target memory utilization percentage for auto-scaling"
  type        = number
  default     = 80
}

# Environment Variables for Container
variable "environment_variables" {
  description = "Environment variables to pass to the container"
  type        = map(string)
  default     = {}
}

variable "enable_execute_command" {
  description = "Enable ECS Exec for debugging containers"
  type        = bool
  default     = true # Useful for development debugging
}