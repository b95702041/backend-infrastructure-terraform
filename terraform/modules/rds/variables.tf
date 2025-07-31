# terraform/modules/rds/variables.tf
# Input variables for the RDS module

variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where RDS will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for RDS subnet group"
  type        = list(string)
}

variable "vpc_cidr_block" {
  description = "CIDR block of the VPC for security group rules"
  type        = string
}

# Database Configuration
variable "db_name" {
  description = "Name of the database to create"
  type        = string
  default     = "backend_db"
}

variable "db_username" {
  description = "Master username for the database"
  type        = string
  default     = "postgres"
}

variable "db_port" {
  description = "Port for the database"
  type        = number
  default     = 5432
}

variable "engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "16"  # Use PostgreSQL 16 (latest major version)
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"  # Good for dev, change for staging/prod
}

variable "allocated_storage" {
  description = "Allocated storage for RDS instance (GB)"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum allocated storage for autoscaling (GB)"
  type        = number
  default     = 100
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment for high availability"
  type        = bool
  default     = false  # false for dev, true for staging/prod
}

variable "backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Preferred backup window"
  type        = string
  default     = "03:00-04:00"  # UTC time
}

variable "maintenance_window" {
  description = "Preferred maintenance window"
  type        = string
  default     = "sun:04:00-sun:05:00"  # UTC time
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false  # false for dev, true for prod
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when deleting"
  type        = bool
  default     = true   # true for dev, false for prod
}