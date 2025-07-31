# terraform/modules/rds/main.tf
# PostgreSQL RDS instance with Secrets Manager integration

# Generate random password for the database
resource "random_password" "db_password" {
  length  = 16
  special = true
}

# Store database credentials in AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "${var.project_name}-${var.environment}-db-credentials"
  description = "Database credentials for ${var.project_name} ${var.environment}"
  
  tags = {
    Name = "${var.project_name}-${var.environment}-db-secret"
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
    engine   = "postgres"
    host     = aws_db_instance.main.endpoint
    port     = var.db_port
    dbname   = var.db_name
  })
}

# Create DB subnet group
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-${var.environment}-db-subnet-group"
  }
}

# Security group for RDS
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-${var.environment}-rds-sg"
  description = "Security group for RDS PostgreSQL database"
  vpc_id      = var.vpc_id

  # Allow inbound PostgreSQL traffic from VPC
  ingress {
    description = "PostgreSQL from VPC"
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  # Allow all outbound traffic (for maintenance, etc.)
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-rds-sg"
  }
}

# RDS Parameter Group (using defaults to keep costs low)
resource "aws_db_parameter_group" "main" {
  family = "postgres16"
  name   = "${var.project_name}-${var.environment}-postgres16"

  tags = {
    Name = "${var.project_name}-${var.environment}-postgres16"
  }
}

# Main RDS instance
resource "aws_db_instance" "main" {
  # Basic Configuration
  identifier = "${var.project_name}-${var.environment}-postgres"
  
  # Engine Configuration
  engine                = "postgres"
  engine_version        = var.engine_version
  instance_class        = var.instance_class
  parameter_group_name  = aws_db_parameter_group.main.name
  
  # Database Configuration
  db_name  = var.db_name
  username = var.db_username
  password = random_password.db_password.result
  port     = var.db_port
  
  # Storage Configuration
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type         = "gp2"
  storage_encrypted    = true
  
  # Network & Security
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  
  # High Availability & Backups
  multi_az                = var.multi_az
  backup_retention_period = var.backup_retention_period
  backup_window          = var.backup_window
  maintenance_window     = var.maintenance_window
  
  # Deletion Protection
  deletion_protection   = var.deletion_protection
  skip_final_snapshot  = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.project_name}-${var.environment}-final-snapshot"
  
  # Free monitoring options (no enhanced monitoring to avoid IAM role requirement)
  monitoring_interval = 0  # Disable enhanced monitoring
  enabled_cloudwatch_logs_exports = ["postgresql"]
  
  # Performance Insights (Free tier: 7 days retention)
  performance_insights_enabled = true
  performance_insights_retention_period = 7  # Free tier
  
  tags = {
    Name = "${var.project_name}-${var.environment}-postgres"
  }
  
  # Ensure secret is created before RDS instance
  depends_on = [aws_secretsmanager_secret.db_credentials]
}