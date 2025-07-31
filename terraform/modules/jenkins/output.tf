# terraform/modules/jenkins/outputs.tf
# Output values from the Jenkins module

# Jenkins Service
output "jenkins_service_id" {
  description = "ID of the Jenkins ECS service"
  value       = aws_ecs_service.jenkins.id
}

output "jenkins_service_name" {
  description = "Name of the Jenkins ECS service"
  value       = aws_ecs_service.jenkins.name
}

output "jenkins_task_definition_arn" {
  description = "ARN of the Jenkins task definition"
  value       = aws_ecs_task_definition.jenkins.arn
}

# Jenkins Access
output "jenkins_url" {
  description = "URL to access Jenkins"
  value       = "http://${aws_lb.jenkins.dns_name}"
}

output "jenkins_alb_dns_name" {
  description = "DNS name of the Jenkins Application Load Balancer"
  value       = aws_lb.jenkins.dns_name
}

output "jenkins_alb_arn" {
  description = "ARN of the Jenkins Application Load Balancer"
  value       = aws_lb.jenkins.arn
}

output "jenkins_alb_zone_id" {
  description = "Zone ID of the Jenkins Application Load Balancer"
  value       = aws_lb.jenkins.zone_id
}

# Jenkins Credentials
output "jenkins_admin_user" {
  description = "Jenkins admin username"
  value       = var.jenkins_admin_user
}

output "jenkins_credentials_secret_arn" {
  description = "ARN of the Secrets Manager secret containing Jenkins credentials"
  value       = aws_secretsmanager_secret.jenkins_credentials.arn
}

output "jenkins_credentials_secret_name" {
  description = "Name of the Secrets Manager secret containing Jenkins credentials"
  value       = aws_secretsmanager_secret.jenkins_credentials.name
}

# ECR Repository
output "ecr_repository_url" {
  description = "URL of the ECR repository for application images"
  value       = var.create_ecr_repository ? aws_ecr_repository.main[0].repository_url : null
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  value       = var.create_ecr_repository ? aws_ecr_repository.main[0].arn : null
}

output "ecr_repository_name" {
  description = "Name of the ECR repository"
  value       = var.create_ecr_repository ? aws_ecr_repository.main[0].name : null
}

# EFS Storage
output "jenkins_efs_file_system_id" {
  description = "ID of the EFS file system for Jenkins"
  value       = var.jenkins_efs_enabled ? aws_efs_file_system.jenkins[0].id : null
}

output "jenkins_efs_dns_name" {
  description = "DNS name of the EFS file system"
  value       = var.jenkins_efs_enabled ? aws_efs_file_system.jenkins[0].dns_name : null
}

# Security Groups
output "jenkins_security_group_id" {
  description = "ID of the Jenkins tasks security group"
  value       = aws_security_group.jenkins_tasks.id
}

output "jenkins_alb_security_group_id" {
  description = "ID of the Jenkins ALB security group"
  value       = aws_security_group.jenkins_alb.id
}

# IAM Roles
output "jenkins_task_execution_role_arn" {
  description = "ARN of the Jenkins task execution role"
  value       = aws_iam_role.jenkins_task_execution_role.arn
}

output "jenkins_task_role_arn" {
  description = "ARN of the Jenkins task role"
  value       = aws_iam_role.jenkins_task_role.arn
}

# CloudWatch
output "jenkins_log_group_name" {
  description = "Name of the Jenkins CloudWatch log group"
  value       = aws_cloudwatch_log_group.jenkins_logs.name
}

output "jenkins_log_group_arn" {
  description = "ARN of the Jenkins CloudWatch log group"
  value       = aws_cloudwatch_log_group.jenkins_logs.arn
}

# Pipeline Information
output "pipeline_ecr_login_command" {
  description = "Command to login to ECR for Docker builds"
  value       = var.create_ecr_repository ? "aws ecr get-login-password --region ${data.aws_region.current.name} | docker login --username AWS --password-stdin ${aws_ecr_repository.main[0].repository_url}" : null
}

output "pipeline_docker_build_command" {
  description = "Example Docker build command for CI/CD pipeline"
  value       = var.create_ecr_repository ? "docker build -t ${aws_ecr_repository.main[0].repository_url}:latest ." : null
}

output "pipeline_docker_push_command" {
  description = "Example Docker push command for CI/CD pipeline"
  value       = var.create_ecr_repository ? "docker push ${aws_ecr_repository.main[0].repository_url}:latest" : null
}