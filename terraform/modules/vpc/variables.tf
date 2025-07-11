# terraform/modules/vpc/variables.tf
# Input variables for the VPC module

variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availability_zone_count" {
  description = "Number of availability zones to use"
  type        = number
  
  validation {
    condition     = var.availability_zone_count >= 2 && var.availability_zone_count <= 4
    error_message = "Availability zone count must be between 2 and 4."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}
