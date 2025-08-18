#!/bin/bash

# AWS Deployment Script for proj Application using Cheetah Infrastructure
# This script deploys the ideas management app to AWS using free tier resources

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
AWS_REGION="${AWS_REGION:-us-east-1}"
PROJECT_NAME="proj"
ENVIRONMENT="prod"
ECR_REPO_BACKEND="${PROJECT_NAME}-backend"
ECR_REPO_FRONTEND="${PROJECT_NAME}-frontend"

echo -e "${BLUE}🚀 Starting AWS deployment for ${PROJECT_NAME} application${NC}"

# Function to print status
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check prerequisites
echo -e "${BLUE}📋 Checking prerequisites...${NC}"

if ! command -v aws &> /dev/null; then
    print_error "AWS CLI not found. Please install AWS CLI first."
    exit 1
fi

if ! command -v terraform &> /dev/null; then
    print_error "Terraform not found. Please install Terraform first."
    exit 1
fi

if ! command -v docker &> /dev/null; then
    print_error "Docker not found. Please install Docker first."
    exit 1
fi

if ! command -v kubectl &> /dev/null; then
    print_error "kubectl not found. Please install kubectl first."
    exit 1
fi

print_status "All prerequisites found"

# Check AWS credentials
echo -e "${BLUE}🔐 Checking AWS credentials...${NC}"
if ! aws sts get-caller-identity &> /dev/null; then
    print_error "AWS credentials not configured. Please run 'aws configure' first."
    exit 1
fi

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
print_status "AWS credentials configured for account: $AWS_ACCOUNT_ID"

# Create ECR repositories if they don't exist
echo -e "${BLUE}📦 Setting up ECR repositories...${NC}"

create_ecr_repo() {
    local repo_name=$1
    if ! aws ecr describe-repositories --repository-names $repo_name --region $AWS_REGION &> /dev/null; then
        echo "Creating ECR repository: $repo_name"
        aws ecr create-repository --repository-name $repo_name --region $AWS_REGION
        print_status "Created ECR repository: $repo_name"
    else
        print_status "ECR repository exists: $repo_name"
    fi
}

create_ecr_repo $ECR_REPO_BACKEND
create_ecr_repo $ECR_REPO_FRONTEND

# Build and push Docker images
echo -e "${BLUE}🏗️ Building and pushing Docker images...${NC}"

# Login to ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Build backend image
echo "Building backend image..."
docker build -t $ECR_REPO_BACKEND:latest ./backend/
docker tag $ECR_REPO_BACKEND:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_BACKEND:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_BACKEND:latest
print_status "Backend image pushed to ECR"

# Build frontend image
echo "Building frontend image..."
docker build -t $ECR_REPO_FRONTEND:latest ./frontend/
docker tag $ECR_REPO_FRONTEND:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_FRONTEND:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_FRONTEND:latest
print_status "Frontend image pushed to ECR"

# Deploy infrastructure with Terraform
echo -e "${BLUE}🏗️ Deploying infrastructure with Terraform...${NC}"

# Initialize Terraform
terraform init

# Create terraform.tfvars for AWS deployment
cat > terraform.tfvars << EOF
aws_region = "$AWS_REGION"
database_password = "proj_secure_password_2025"
EOF

# Plan deployment
echo "Planning Terraform deployment..."
terraform plan -var-file=terraform.tfvars

# Apply deployment
echo "Applying Terraform configuration..."
if terraform apply -var-file=terraform.tfvars -auto-approve; then
    print_status "Infrastructure deployed successfully"
else
    print_error "Infrastructure deployment failed"
    exit 1
fi

# Get cluster information
CLUSTER_NAME=$(terraform output -raw cluster_name)
CLUSTER_ENDPOINT=$(terraform output -raw cluster_endpoint)
DATABASE_ENDPOINT=$(terraform output -raw database_endpoint)

print_status "Cluster Name: $CLUSTER_NAME"
print_status "Cluster Endpoint: $CLUSTER_ENDPOINT"
print_status "Database Endpoint: $DATABASE_ENDPOINT"

# Configure kubectl
echo -e "${BLUE}⚙️ Configuring kubectl...${NC}"
aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME
print_status "kubectl configured for EKS cluster"

# Wait for cluster to be ready
echo -e "${BLUE}⏳ Waiting for cluster to be ready...${NC}"
kubectl wait --for=condition=Ready nodes --all --timeout=300s
print_status "Cluster nodes are ready"

# Update Kubernetes manifests with ECR image URIs
echo -e "${BLUE}📝 Updating Kubernetes manifests...${NC}"
sed -i.bak "s|proj-backend:latest|$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_BACKEND:latest|g" kubernetes-aws.yaml
sed -i.bak "s|proj-frontend:latest|$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_FRONTEND:latest|g" kubernetes-aws.yaml
sed -i.bak "s|proj-prod-database.cluster-ro.amazonaws.com|$DATABASE_ENDPOINT|g" kubernetes-aws.yaml

# Deploy application to Kubernetes
echo -e "${BLUE}🚀 Deploying application to Kubernetes...${NC}"
kubectl apply -f kubernetes-aws.yaml
print_status "Application manifests deployed"

# Wait for deployments to be ready
echo -e "${BLUE}⏳ Waiting for application deployments...${NC}"
kubectl wait --for=condition=available --timeout=300s deployment/proj-backend -n proj-app
kubectl wait --for=condition=available --timeout=300s deployment/proj-frontend -n proj-app
print_status "Application deployments are ready"

# Get application URL
echo -e "${BLUE}🌐 Getting application URL...${NC}"
sleep 30  # Wait for load balancer to be provisioned

if kubectl get ingress proj-ingress -n proj-app &> /dev/null; then
    LOAD_BALANCER_URL=$(kubectl get ingress proj-ingress -n proj-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
    if [ -n "$LOAD_BALANCER_URL" ]; then
        APP_URL="http://$LOAD_BALANCER_URL"
        print_status "Application URL: $APP_URL"
    else
        print_warning "Load balancer URL not yet available. Check again in a few minutes."
        echo "Run: kubectl get ingress proj-ingress -n proj-app"
    fi
else
    print_warning "Ingress not found. Checking service instead..."
    kubectl get services -n proj-app
fi

# Display deployment summary
echo -e "${GREEN}"
echo "=============================================="
echo "🎉 AWS Deployment Complete!"
echo "=============================================="
echo -e "${NC}"
echo "Project: $PROJECT_NAME"
echo "Environment: $ENVIRONMENT"
echo "AWS Region: $AWS_REGION"
echo "Cluster: $CLUSTER_NAME"
echo "Database: $DATABASE_ENDPOINT"
if [ -n "$APP_URL" ]; then
    echo "Application URL: $APP_URL"
fi
echo ""
echo "Useful commands:"
echo "  kubectl get pods -n proj-app"
echo "  kubectl logs -f deployment/proj-backend -n proj-app"
echo "  kubectl logs -f deployment/proj-frontend -n proj-app"
echo "  kubectl get ingress -n proj-app"
echo ""
echo "To clean up resources:"
echo "  terraform destroy -var-file=terraform.tfvars"
echo "=============================================="

print_status "Deployment completed successfully!"
