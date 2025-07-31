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

# Create ECS cluster with Fargate and Application Load Balancer
module "ecs" {
  source = "../../modules/ecs"
  
  project_name       = var.project_name
  environment        = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  vpc_cidr_block    = module.vpc.vpc_cidr_block
  
  # Database integration
  db_endpoint               = module.rds.db_endpoint
  db_port                  = module.rds.db_port
  db_security_group_id     = module.rds.db_security_group_id
  secrets_manager_secret_arn = module.rds.secrets_manager_secret_arn
  
  # ECS configuration for dev environment
  service_name     = var.ecs_service_name
  container_image  = var.ecs_container_image
  container_port   = var.ecs_container_port
  container_cpu    = var.ecs_container_cpu
  container_memory = var.ecs_container_memory
  desired_count    = var.ecs_desired_count
  
  # Load balancer and scaling
  enable_load_balancer = var.ecs_enable_load_balancer
  enable_auto_scaling  = var.ecs_enable_auto_scaling
  health_check_path    = var.ecs_health_check_path
  
  # Development-specific settings
  enable_execute_command = true  # Enable ECS Exec for debugging
}

# Create Jenkins CI/CD platform
module "jenkins" {
  source = "../../modules/jenkins"
  
  project_name       = var.project_name
  environment        = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  vpc_cidr_block    = module.vpc.vpc_cidr_block
  
  # ECS Cluster integration
  ecs_cluster_id     = module.ecs.cluster_id
  ecs_cluster_name   = module.ecs.cluster_name
  ecs_service_name   = module.ecs.service_name
  
  # Database integration
  db_endpoint               = module.rds.db_endpoint
  secrets_manager_secret_arn = module.rds.secrets_manager_secret_arn
  
  # Jenkins configuration for dev environment
  jenkins_admin_user     = var.jenkins_admin_user
  jenkins_admin_password = var.jenkins_admin_password
  jenkins_cpu           = var.jenkins_cpu
  jenkins_memory        = var.jenkins_memory
  jenkins_desired_count = var.jenkins_desired_count
  
  # Container registry
  create_ecr_repository = var.jenkins_create_ecr_repository
  ecr_repository_name   = var.jenkins_ecr_repository_name
  
  # Storage and security
  jenkins_efs_enabled     = var.jenkins_efs_enabled
  allowed_cidr_blocks     = var.jenkins_allowed_cidr_blocks
  
  # Pipeline configuration  
  default_git_repository = var.jenkins_default_git_repository
}