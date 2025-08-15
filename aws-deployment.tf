# AWS Free Tier Deployment for proj Application using Cheetah Platform
# This configuration uses AWS free tier resources wherever possible

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "proj"
      Environment = "dev"
      ManagedBy   = "cheetah"
      Owner       = "proj-team"
    }
  }
}

# Use Cheetah infrastructure platform
module "cheetah" {
  source = "./infrastructure/cheetah/terraform"
  
  # Core configuration
  cloud_provider = "aws"
  region         = var.aws_region
  project_name   = "proj"
  environment    = "dev"
  gcp_project_id = null  # Not needed for AWS deployment
  
  # Networking configuration
  vpc_cidr                = "10.0.0.0/16"
  availability_zones      = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnet_cidrs    = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet_cidrs     = ["10.0.101.0/24", "10.0.102.0/24"]
  
  # Kubernetes cluster configuration (free tier optimized)
  kubernetes_version = "1.28"
  node_groups = [
    {
      name           = "general"
      instance_types = ["t3.micro"]    # Free tier eligible
      capacity_type  = "ON_DEMAND"
      min_size       = 1
      max_size       = 2
      desired_size   = 1               # Start with 1 node
      disk_size      = 20              # 20GB within free tier
      launch_template = null
    }
  ]
  
  # Database configuration (free tier optimized)
  database_config = {
    engine            = "postgres"
    engine_version    = "14"
    instance_class    = "db.t3.micro"  # AWS free tier eligible
    allocated_storage = 20             # 20GB RDS storage (free tier)
    database_name     = "ideas_db"
    master_username   = "postgres"
    master_password   = var.database_password
  }
  
  # Disable monitoring to reduce costs
  enable_monitoring = false
}

# Variables
variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
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
  value       = module.cheetah.cluster_endpoint
  sensitive   = true
}

output "cluster_name" {
  description = "Kubernetes cluster name"
  value       = module.cheetah.cluster_name
}

output "database_endpoint" {
  description = "Database endpoint"
  value       = module.cheetah.database_endpoint
  sensitive   = true
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.cheetah.vpc_id
}

output "kubectl_config" {
  description = "kubectl configuration command"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.cheetah.cluster_name}"
}
