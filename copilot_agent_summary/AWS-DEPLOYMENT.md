# 🐆 AWS Deployment Guide using Cheetah Platform

This guide will help you deploy the proj application to AWS using the Cheetah cloud-agnostic infrastructure platform, optimized for AWS Free Tier resources.

## 🎯 What You'll Deploy

- **EKS Kubernetes Cluster** with t3.micro nodes (free tier eligible)
- **RDS PostgreSQL Database** with db.t3.micro instance (free tier eligible)
- **VPC with Security Groups** for network isolation
- **ECR Container Registry** for Docker images
- **Application Load Balancer** for public access
- **Complete proj application** (FastAPI backend + React frontend)

## 💰 AWS Free Tier Usage

This deployment is optimized for AWS Free Tier:
- **EKS**: 750 hours/month of t3.micro instances
- **RDS**: 750 hours/month of db.t3.micro + 20GB storage
- **VPC**: No additional charges for basic VPC usage
- **ECR**: 500 MB of storage per month
- **ALB**: 750 hours/month + 15 GB data processing

## 📋 Prerequisites

### 1. Install Required Tools

```bash
# Install AWS CLI
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /

# Install Terraform
brew install terraform

# Install kubectl
brew install kubectl

# Verify Docker is installed
docker --version
```

### 2. Configure AWS Credentials

```bash
# Configure AWS CLI with your credentials
aws configure

# Verify configuration
aws sts get-caller-identity
```

**Required AWS Permissions:**
- EC2 full access (for EKS nodes and VPC)
- EKS full access (for Kubernetes cluster)
- RDS full access (for PostgreSQL database)
- ECR full access (for container registry)
- IAM permissions for creating roles and policies

### 3. Clone Repository with Submodules

```bash
git clone --recursive https://github.com/vtrao/proj.git
cd proj

# Or if already cloned, initialize submodules
git submodule update --init --recursive
```

## 🚀 Deployment Steps

### 1. Deploy Infrastructure and Application

```bash
# Run the automated deployment script
./deploy-aws-cheetah.sh
```

This script will:
1. ✅ Validate prerequisites and AWS credentials
2. 🏗️ Initialize Terraform with Cheetah modules
3. 📋 Plan and apply infrastructure deployment
4. ⚙️ Configure kubectl for the new EKS cluster
5. 🐳 Build and push Docker images to ECR
6. ☸️ Deploy application to Kubernetes
7. 🌐 Provide access URLs

### 2. Monitor Deployment Progress

```bash
# Watch cluster nodes come online
kubectl get nodes -w

# Monitor application pods
kubectl get pods -n proj-app -w

# Check application logs
kubectl logs -f deployment/proj-backend -n proj-app
kubectl logs -f deployment/proj-frontend -n proj-app
```

### 3. Access Your Application

```bash
# Get the application URL
kubectl get service proj-frontend-service -n proj-app

# Test the API
curl http://<load-balancer-url>/api/ideas
```

## 🔧 Manual Deployment (Step by Step)

If you prefer manual control:

### 1. Initialize Terraform

```bash
terraform init
terraform validate
```

### 2. Plan and Apply Infrastructure

```bash
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

### 3. Configure kubectl

```bash
aws eks update-kubeconfig --region us-east-1 --name $(terraform output -raw cluster_name)
```

### 4. Build and Push Images

```bash
# Get ECR login token
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com

# Build and push backend
docker build -t proj-backend ./backend/
docker tag proj-backend:latest $(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com/proj-backend:latest
docker push $(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com/proj-backend:latest

# Build and push frontend
docker build -t proj-frontend ./frontend/
docker tag proj-frontend:latest $(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com/proj-frontend:latest
docker push $(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com/proj-frontend:latest
```

### 5. Deploy to Kubernetes

```bash
# The deploy script creates k8s-deployment.yaml automatically
kubectl apply -f k8s-deployment.yaml
```

## 🛠️ Useful Commands

### Application Management

```bash
# Check application status
kubectl get all -n proj-app

# Scale application
kubectl scale deployment proj-backend --replicas=2 -n proj-app
kubectl scale deployment proj-frontend --replicas=2 -n proj-app

# Update application
docker build -t proj-backend ./backend/
docker tag proj-backend:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/proj-backend:latest
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/proj-backend:latest
kubectl rollout restart deployment/proj-backend -n proj-app
```

### Troubleshooting

```bash
# Debug pods
kubectl describe pod <pod-name> -n proj-app
kubectl logs <pod-name> -n proj-app

# Check ingress
kubectl describe ingress proj-ingress -n proj-app

# Test database connection
kubectl exec -it deployment/proj-backend -n proj-app -- python -c "
import psycopg2
import os
conn = psycopg2.connect(os.environ['DATABASE_URL'])
print('Database connection successful!')
"
```

### Infrastructure Management

```bash
# Check Terraform state
terraform show
terraform output

# Update infrastructure
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

## 🧹 Cleanup

When you're done testing, clean up all resources to avoid charges:

```bash
# Run the automated cleanup script
./cleanup-aws.sh

# Or manually:
kubectl delete namespace proj-app
terraform destroy -var-file=terraform.tfvars
```

## 🔍 Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        AWS Cloud                            │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                       VPC                               │ │
│  │                                                         │ │
│  │  ┌──────────────────┐    ┌──────────────────┐         │ │
│  │  │   Public Subnet  │    │  Private Subnet  │         │ │
│  │  │                  │    │                  │         │ │
│  │  │ ┌──────────────┐ │    │ ┌──────────────┐ │         │ │
│  │  │ │     ALB      │ │    │ │  EKS Nodes   │ │         │ │
│  │  │ └──────────────┘ │    │ └──────────────┘ │         │ │
│  │  └──────────────────┘    │                  │         │ │
│  │                          │ ┌──────────────┐ │         │ │
│  │                          │ │ RDS PostgreSQL│ │         │ │
│  │                          │ └──────────────┘ │         │ │
│  │                          └──────────────────┘         │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                       ECR                               │ │
│  │  ┌─────────────────┐  ┌─────────────────┐              │ │
│  │  │  proj-backend   │  │  proj-frontend  │              │ │
│  │  └─────────────────┘  └─────────────────┘              │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## 📚 Additional Resources

- [Cheetah Platform Documentation](./infrastructure/cheetah/README.md)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [AWS Free Tier Details](https://aws.amazon.com/free/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

## 🆘 Support

If you encounter issues:

1. Check the [troubleshooting section](#troubleshooting)
2. Review AWS CloudWatch logs
3. Verify AWS service limits
4. Check kubectl and AWS CLI configurations

---

**Powered by 🐆 Cheetah Platform - Deploy at the speed of light!**
