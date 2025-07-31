# terraform/modules/jenkins/main.tf
# Jenkins CI/CD platform with ECS Fargate, ECR, and EFS storage

# Local values for naming consistency
locals {
  jenkins_name = "${var.project_name}-${var.environment}-jenkins"
  ecr_repository_name = var.ecr_repository_name != null ? var.ecr_repository_name : "${var.project_name}-${var.environment}"
}

# Generate random password for Jenkins admin if not provided
resource "random_password" "jenkins_admin_password" {
  count   = var.jenkins_admin_password == null ? 1 : 0
  length  = 16
  special = true
}

# Store Jenkins admin credentials in Secrets Manager
resource "aws_secretsmanager_secret" "jenkins_credentials" {
  name        = "${local.jenkins_name}-credentials"
  description = "Jenkins admin credentials for ${var.project_name} ${var.environment}"
  
  tags = {
    Name = "${local.jenkins_name}-credentials"
  }
}

resource "aws_secretsmanager_secret_version" "jenkins_credentials" {
  secret_id = aws_secretsmanager_secret.jenkins_credentials.id
  secret_string = jsonencode({
    username = var.jenkins_admin_user
    password = var.jenkins_admin_password != null ? var.jenkins_admin_password : random_password.jenkins_admin_password[0].result
  })
}

# ECR Repository for application Docker images
resource "aws_ecr_repository" "main" {
  count = var.create_ecr_repository ? 1 : 0
  
  name                 = local.ecr_repository_name
  image_tag_mutability = var.ecr_image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.ecr_scan_on_push
  }

  tags = {
    Name = local.ecr_repository_name
  }
}

# ECR Repository Policy
resource "aws_ecr_repository_policy" "main" {
  count = var.create_ecr_repository ? 1 : 0
  
  repository = aws_ecr_repository.main[0].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPushPull"
        Effect = "Allow"
        Principal = {
          AWS = [
            aws_iam_role.jenkins_task_execution_role.arn,
            aws_iam_role.jenkins_task_role.arn
          ]
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
      }
    ]
  })
}

# EFS File System for Jenkins persistent storage
resource "aws_efs_file_system" "jenkins" {
  count = var.jenkins_efs_enabled ? 1 : 0
  
  creation_token   = local.jenkins_name
  performance_mode = var.jenkins_efs_performance_mode
  throughput_mode  = var.jenkins_efs_throughput_mode
  encrypted        = true
  # Use default AWS managed key for EFS encryption
  # kms_key_id is omitted to use aws/elasticfilesystem default key

  tags = {
    Name = "${local.jenkins_name}-efs"
  }
}

# EFS Mount Targets (one per private subnet)
resource "aws_efs_mount_target" "jenkins" {
  count = var.jenkins_efs_enabled ? length(var.private_subnet_ids) : 0
  
  file_system_id  = aws_efs_file_system.jenkins[0].id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [aws_security_group.jenkins_efs[0].id]
}

# Security Group for EFS
resource "aws_security_group" "jenkins_efs" {
  count = var.jenkins_efs_enabled ? 1 : 0
  
  name        = "${local.jenkins_name}-efs-sg"
  description = "Security group for Jenkins EFS"
  vpc_id      = var.vpc_id

  ingress {
    description     = "NFS from Jenkins tasks"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_tasks.id]
  }

  tags = {
    Name = "${local.jenkins_name}-efs-sg"
  }
}

# IAM Role for Jenkins Task Execution
resource "aws_iam_role" "jenkins_task_execution_role" {
  name = "${local.jenkins_name}-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${local.jenkins_name}-task-execution-role"
  }
}

# Attach ECS task execution policy
resource "aws_iam_role_policy_attachment" "jenkins_task_execution_role_policy" {
  role       = aws_iam_role.jenkins_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# IAM policy for Jenkins to access Secrets Manager
resource "aws_iam_role_policy" "jenkins_secrets_policy" {
  name = "${local.jenkins_name}-secrets-policy"
  role = aws_iam_role.jenkins_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          aws_secretsmanager_secret.jenkins_credentials.arn,
          var.secrets_manager_secret_arn
        ]
      }
    ]
  })
}

# IAM Role for Jenkins Task (application runtime)
resource "aws_iam_role" "jenkins_task_role" {
  name = "${local.jenkins_name}-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${local.jenkins_name}-task-role"
  }
}

# IAM policy for Jenkins to manage ECS deployments
resource "aws_iam_role_policy" "jenkins_ecs_policy" {
  name = "${local.jenkins_name}-ecs-policy"
  role = aws_iam_role.jenkins_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition",
          "ecs:ListTasks",
          "ecs:DescribeTasks"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = "*"
        Condition = {
          StringLike = {
            "iam:PassedToService" = "ecs-tasks.amazonaws.com"
          }
        }
      }
    ]
  })
}

# CloudWatch Log Group for Jenkins
resource "aws_cloudwatch_log_group" "jenkins_logs" {
  name              = "/ecs/${local.jenkins_name}"
  retention_in_days = 7

  tags = {
    Name = "${local.jenkins_name}-logs"
  }
}

# Security Group for Jenkins Tasks
resource "aws_security_group" "jenkins_tasks" {
  name        = "${local.jenkins_name}-tasks-sg"
  description = "Security group for Jenkins ECS tasks"
  vpc_id      = var.vpc_id

  # Allow inbound traffic from ALB
  ingress {
    description     = "HTTP from ALB"
    from_port       = var.jenkins_container_port
    to_port         = var.jenkins_container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_alb.id]
  }

  # Allow all outbound traffic (for Git, Docker registry, etc.)
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.jenkins_name}-tasks-sg"
  }
}

# Security Group for Jenkins Application Load Balancer
resource "aws_security_group" "jenkins_alb" {
  name        = "${local.jenkins_name}-alb-sg"
  description = "Security group for Jenkins Application Load Balancer"
  vpc_id      = var.vpc_id

  # Allow HTTP inbound traffic
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # Allow HTTPS inbound traffic
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # Allow all outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.jenkins_name}-alb-sg"
  }
}

# Application Load Balancer for Jenkins
resource "aws_lb" "jenkins" {
  name               = "${var.project_name}-${var.environment}-ci"  # Shortened to "ci" for CI/CD
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.jenkins_alb.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-${var.environment}-jenkins-alb"
  }
}

# ALB Target Group for Jenkins
resource "aws_lb_target_group" "jenkins" {
  name        = "${var.project_name}-${var.environment}-ci-tg"  # Shortened to "ci-tg"
  port        = var.jenkins_container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = var.healthy_threshold
    interval            = var.jenkins_health_check_interval
    matcher             = "200,403"  # Jenkins login page returns 403 for unauthenticated requests
    path                = var.jenkins_health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = var.jenkins_health_check_timeout
    unhealthy_threshold = var.unhealthy_threshold
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-jenkins-tg"
  }
}

# ALB Listener for Jenkins
resource "aws_lb_listener" "jenkins" {
  load_balancer_arn = aws_lb.jenkins.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins.arn
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-jenkins-listener"
  }
}

# Data source for current AWS region
data "aws_region" "current" {}

# ECS Task Definition for Jenkins
resource "aws_ecs_task_definition" "jenkins" {
  family                   = local.jenkins_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.jenkins_cpu
  memory                   = var.jenkins_memory
  execution_role_arn       = aws_iam_role.jenkins_task_execution_role.arn
  task_role_arn           = aws_iam_role.jenkins_task_role.arn

  # EFS volume configuration
  dynamic "volume" {
    for_each = var.jenkins_efs_enabled ? [1] : []
    content {
      name = "jenkins-home"
      efs_volume_configuration {
        file_system_id = aws_efs_file_system.jenkins[0].id
        root_directory = "/"
      }
    }
  }

  container_definitions = jsonencode([
    {
      name  = "jenkins"
      image = var.jenkins_container_image

      portMappings = [
        {
          containerPort = var.jenkins_container_port
          hostPort      = var.jenkins_container_port
          protocol      = "tcp"
        }
      ]

      # Environment variables
      environment = [
        for key, value in merge(
          var.jenkins_environment_variables,
          {
            AWS_DEFAULT_REGION = data.aws_region.current.name
            ECR_REPOSITORY_URI = var.create_ecr_repository ? aws_ecr_repository.main[0].repository_url : ""
            ECS_CLUSTER_NAME   = var.ecs_cluster_name
            ECS_SERVICE_NAME   = var.ecs_service_name
            DB_ENDPOINT        = var.db_endpoint
          }
        ) : {
          name  = key
          value = value
        }
      ]

      # Secrets from Secrets Manager
      secrets = [
        {
          name      = "JENKINS_ADMIN_CREDENTIALS"
          valueFrom = aws_secretsmanager_secret.jenkins_credentials.arn
        },
        {
          name      = "DB_CREDENTIALS"
          valueFrom = var.secrets_manager_secret_arn
        }
      ]

      # Mount EFS volume if enabled
      mountPoints = var.jenkins_efs_enabled ? [
        {
          sourceVolume  = "jenkins-home"
          containerPath = "/var/jenkins_home"
          readOnly      = false
        }
      ] : []

      # Logging configuration
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.jenkins_logs.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }

      essential = true
    }
  ])

  tags = {
    Name = local.jenkins_name
  }
}

# ECS Service for Jenkins
resource "aws_ecs_service" "jenkins" {
  name            = "jenkins"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.jenkins.arn
  desired_count   = var.jenkins_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.jenkins_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.jenkins.arn
    container_name   = "jenkins"
    container_port   = var.jenkins_container_port
  }

  depends_on = [aws_lb_listener.jenkins]

  tags = {
    Name = "${local.jenkins_name}-service"
  }
}