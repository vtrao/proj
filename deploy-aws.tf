# AWS Free Tier Deployment Configuration for proj Application
# This configuration uses AWS free tier resources to deploy the ideas management app

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Use the Cheetah infrastructure platform
module "cheetah_infrastructure" {
  source = "./infrastructure/cheetah/terraform"
  
  # Core configuration
  cloud_provider = "aws"
  region         = var.aws_region
  project_name   = "proj"
  environment    = "prod"
  
  # Networking (free tier optimized)
  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24"]
  
  # Kubernetes cluster (free tier: t3.micro nodes)
  kubernetes_version = "1.28"
  node_groups = {
    main = {
      instance_types = ["t3.micro"]  # Free tier eligible
      min_size       = 1
      max_size       = 2
      desired_size   = 1  # Start with 1 node to stay in free tier
      disk_size      = 20  # 20GB is within free tier
    }
  }
  
  # Database configuration (free tier: db.t3.micro)
  database_config = {
    engine            = "postgres"
    engine_version    = "15.4"
    instance_class    = "micro"  # Maps to db.t3.micro (free tier)
    allocated_storage = 20       # 20GB is within free tier
    database_name     = "ideas_db"
    master_username   = "postgres"
    master_password   = var.database_password
  }
  
  # Application configuration
  app_config = {
    image             = "proj-backend"  # Will be built and pushed
    tag               = "latest"
    replicas          = 1  # Single replica for free tier
    port              = 8000
    health_check_path = "/api/ideas"
    resources = {
      requests = {
        cpu    = "100m"   # Minimal CPU request
        memory = "128Mi"  # Minimal memory for free tier
      }
      limits = {
        cpu    = "250m"   # Conservative CPU limit
        memory = "256Mi"  # Conservative memory limit
      }
    }
  }
  
  # Optional features (optimized for free tier)
  enable_monitoring   = false  # Disable to save costs
  enable_autoscaling  = false  # Manual scaling for free tier
  enable_ingress      = true   # Keep ingress for web access
}

# Variables
variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"  # Free tier has good availability here
}

variable "database_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
  default     = "proj_secure_password_2025"
}

# Outputs
output "cluster_endpoint" {
  description = "Kubernetes cluster endpoint"
  value       = module.cheetah_infrastructure.cluster_endpoint
}

output "cluster_name" {
  description = "Kubernetes cluster name"
  value       = module.cheetah_infrastructure.cluster_name
}

output "database_endpoint" {
  description = "Database endpoint"
  value       = module.cheetah_infrastructure.database_endpoint
}

output "load_balancer_dns" {
  description = "Load balancer DNS name"
  value       = module.cheetah_infrastructure.load_balancer_dns
}

output "application_url" {
  description = "Application URL"
  value       = "http://${module.cheetah_infrastructure.load_balancer_dns}"
}
