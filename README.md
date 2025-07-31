# Backend Infrastructure Terraform

Infrastructure as Code for backend services using Terraform on AWS.

## 🏗️ Architecture Overview

Modern, scalable backend infrastructure built with Terraform modules for maximum reusability across environments.

## 🛠️ Technology Stack

- **Infrastructure**: Terraform
- **Containerization**: Docker + ECS
- **Database**: PostgreSQL (RDS)
- **CI/CD**: Jenkins
- **Monitoring**: Prometheus + Grafana
- **Security**: AWS Secrets Manager, VPC isolation

## 📁 Project Structure

```
terraform/
├── environments/
│   ├── dev/           # Development environment
│   ├── staging/       # Staging environment (planned)
│   └── prod/          # Production environment (planned)
└── modules/
    ├── vpc/           # ✅ Network foundation
    ├── rds/           # ✅ PostgreSQL database
    ├── ecs/           # 🔄 Container platform (next)
    ├── monitoring/    # 📋 Prometheus + Grafana (planned)
    └── jenkins/       # 📋 CI/CD pipeline (planned)
```

## 🚀 Deployment Status

### ✅ Completed Infrastructure

#### VPC Module
- Multi-AZ deployment across us-east-1a and us-east-1b
- Public subnets for load balancers and NAT gateways
- Private subnets for secure application and database hosting
- Internet Gateway and NAT Gateways for controlled internet access
- Proper routing tables and security groups

**Network Details:**
- VPC CIDR: `10.0.0.0/16`
- Public Subnets: `10.0.0.0/24`, `10.0.1.0/24`
- Private Subnets: `10.0.2.0/24`, `10.0.3.0/24`

#### RDS Module
- PostgreSQL 16 (latest version)
- Cost-optimized configuration (db.t3.micro, single AZ for dev)
- Encrypted storage with automatic backups
- AWS Secrets Manager integration for secure credentials
- Performance Insights enabled (7-day free retention)
- CloudWatch logs integration
- VPC security groups for network isolation

**Database Features:**
- Engine: PostgreSQL 16
- Instance: db.t3.micro (Free Tier eligible)
- Storage: 20GB GP2 with auto-scaling up to 100GB
- Backups: 7-day retention
- Monitoring: Performance Insights + CloudWatch

### 📋 Planned Infrastructure

- **ECS Module**: Container orchestration platform
- **Application Load Balancer**: API endpoint exposure
- **Jenkins Module**: CI/CD automation
- **Monitoring Module**: Prometheus + Grafana observability

## 🚀 Getting Started

### Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.0 installed
- Git for version control

### Quick Start

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd backend-infrastructure-terraform
   ```

2. **Deploy Development Environment**
   ```bash
   cd terraform/environments/dev
   terraform init
   terraform plan
   terraform apply
   ```

3. **Verify Deployment**
   - Check AWS Console for VPC and RDS resources
   - Verify database connectivity from private subnets
   - Review Secrets Manager for database credentials

### Environment Configuration

Each environment (`dev`, `staging`, `prod`) has its own:
- Terraform state file (isolated deployments)
- Variable configurations
- Resource sizing and settings

**Development Environment:**
- Cost-optimized settings
- Single AZ deployment
- Minimal resource allocation
- Enhanced logging for debugging

## 🔒 Security Features

- **Network Isolation**: Private subnets for sensitive resources
- **Encrypted Storage**: All RDS volumes encrypted at rest
- **Secrets Management**: Database credentials in AWS Secrets Manager
- **Security Groups**: Restrictive ingress/egress rules
- **IAM**: Least privilege access patterns

## 📊 Monitoring & Observability

**Currently Enabled:**
- RDS Performance Insights (7-day retention)
- PostgreSQL query logs in CloudWatch
- Infrastructure metrics and alarms
- VPC Flow Logs for network analysis

**Planned:**
- Prometheus metrics collection
- Grafana dashboards
- Application-level monitoring
- Log aggregation and analysis

## 💰 Cost Optimization

**Development Environment:**
- Free Tier eligible resources where possible
- Single AZ deployment for non-critical workloads
- Right-sized instances (t3.micro for RDS)
- Efficient storage allocation with auto-scaling

**Estimated Monthly Cost (Dev):**
- RDS db.t3.micro: ~$12-15
- NAT Gateways: ~$32-45
- EBS Storage: ~$2-4
- **Total: ~$50-65/month**

## 🏃‍♂️ Next Steps

1. **ECS Module Development**
   - Container cluster setup
   - Task definitions and services
   - Integration with RDS database

2. **Application Load Balancer**
   - Public API endpoints
   - SSL/TLS termination
   - Health check configuration

3. **CI/CD Pipeline**
   - Jenkins setup and configuration
   - Automated container builds
   - Deployment automation

## 🤝 Contributing

1. Create feature branches for new modules
2. Test in development environment first
3. Document all variables and outputs
4. Follow Terraform best practices
5. Update README with changes

## 📖 Module Documentation

### VPC Module
- **Location**: `terraform/modules/vpc/`
- **Purpose**: Network foundation with public/private subnet architecture
- **Outputs**: VPC ID, subnet IDs, gateway IDs for other modules

### RDS Module
- **Location**: `terraform/modules/rds/`
- **Purpose**: Managed PostgreSQL database with security best practices
- **Outputs**: Database endpoint, credentials ARN, security group ID

## 🆘 Troubleshooting

### Common Issues

1. **State Lock Errors**
   ```bash
   terraform force-unlock <lock-id>
   ```

2. **Module Not Found**
   ```bash
   terraform init
   ```

3. **RDS Version Issues**
   - Check AWS documentation for supported PostgreSQL versions
   - Update `engine_version` variable accordingly

### Getting Help

- Check AWS CloudWatch logs for detailed error messages
- Review Terraform state for resource dependencies
- Use `terraform plan` to preview changes before applying

---

**Infrastructure Status**: Foundation Complete ✅  
**Next Milestone**: ECS Container Platform 🎯  
**Last Updated**: January 2025