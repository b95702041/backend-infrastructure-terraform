# terraform/environments/dev/outputs.tf
# Output values from the development environment

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "availability_zones" {
  description = "List of availability zones used"
  value       = module.vpc.availability_zones
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = module.vpc.nat_gateway_ids
}

# Database Outputs
output "database_endpoint" {
  description = "RDS instance endpoint for application connections"
  value       = module.rds.db_endpoint
}

output "database_port" {
  description = "RDS instance port"
  value       = module.rds.db_port
}

output "database_name" {
  description = "Database name"
  value       = module.rds.db_name
}

output "secrets_manager_secret_name" {
  description = "Name of the Secrets Manager secret containing database credentials"
  value       = module.rds.secrets_manager_secret_name
}

# ECS Outputs
output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = module.ecs.service_name
}

output "application_url" {
  description = "Public URL of the application via Application Load Balancer"
  value       = module.ecs.alb_url
}

output "load_balancer_dns" {
  description = "DNS name of the Application Load Balancer"
  value       = module.ecs.alb_dns_name
}

output "ecs_log_group" {
  description = "CloudWatch log group for ECS containers"
  value       = module.ecs.log_group_name
}

# Jenkins Outputs  
output "jenkins_url" {
  description = "URL to access Jenkins CI/CD platform"
  value       = module.jenkins.jenkins_url
}

output "jenkins_admin_user" {
  description = "Jenkins admin username"
  value       = module.jenkins.jenkins_admin_user
}

output "jenkins_credentials_secret_name" {
  description = "Name of the Secrets Manager secret containing Jenkins credentials"
  value       = module.jenkins.jenkins_credentials_secret_name
}

output "ecr_repository_url" {
  description = "ECR repository URL for application Docker images"
  value       = module.jenkins.ecr_repository_url
}

output "ecr_repository_name" {
  description = "ECR repository name"
  value       = module.jenkins.ecr_repository_name
}

output "jenkins_log_group_name" {
  description = "CloudWatch log group for Jenkins"
  value       = module.jenkins.jenkins_log_group_name
}