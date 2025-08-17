#!/bin/bash

# Project AWS Deployment Script using Cheetah Platform
# Optimized for AWS Free Tier

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions for colored output
print_status() {
    echo -e "${BLUE}🐆 [CHEETAH]${NC} $1"
}

print_success() {
    echo -e "${GREEN}✅ [SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️ [WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}❌ [ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}"
    echo "=================================================="
    echo "🐆 Cheetah Cloud Deployment Platform"
    echo "📱 Project: proj"
    echo "☁️ Cloud: AWS (Free Tier Optimized)"
    echo "🌍 Environment: Development"
    echo "=================================================="
    echo -e "${NC}"
}

# Configuration
AWS_REGION="us-east-1"
PROJECT_NAME="proj"
ENVIRONMENT="dev"

print_header

# Check prerequisites
print_status "Checking prerequisites..."

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed. Please install Terraform first."
    exit 1
fi

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI is not installed. Please install AWS CLI first."
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Check if docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

print_success "All prerequisites found"

# Check AWS credentials
print_status "Validating AWS credentials..."
if ! aws sts get-caller-identity &> /dev/null; then
    print_error "AWS credentials not configured. Please run 'aws configure' first."
    exit 1
fi

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
print_success "AWS credentials validated for account: $AWS_ACCOUNT_ID"

# Initialize Terraform
print_status "Initializing Terraform with Cheetah modules..."
terraform init

# Validate Terraform configuration
print_status "Validating Terraform configuration..."
terraform validate
print_success "Terraform configuration is valid"

# Plan deployment
print_status "Planning infrastructure deployment..."
terraform plan -var-file=terraform.tfvars -out=tfplan
print_success "Infrastructure plan created"

# Ask for confirmation
echo ""
print_warning "This will create AWS resources that may incur costs (though optimized for free tier)."
read -p "Do you want to proceed with the deployment? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_status "Deployment cancelled by user"
    exit 0
fi

# Apply infrastructure
print_status "Deploying infrastructure with Cheetah..."
terraform apply tfplan
print_success "Infrastructure deployed successfully"

# Get outputs
CLUSTER_NAME=$(terraform output -raw cluster_name)
CLUSTER_ENDPOINT=$(terraform output -raw cluster_endpoint)
DATABASE_ENDPOINT=$(terraform output -raw database_endpoint)
KUBECTL_CONFIG=$(terraform output -raw kubectl_config)

print_success "Cluster: $CLUSTER_NAME"
print_success "Endpoint: $CLUSTER_ENDPOINT"
print_success "Database: $DATABASE_ENDPOINT"

# Configure kubectl
print_status "Configuring kubectl..."
eval $KUBECTL_CONFIG
print_success "kubectl configured for EKS cluster"

# Wait for cluster to be ready
print_status "Waiting for cluster nodes to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s
print_success "Cluster nodes are ready"

# Create ECR repositories for container images
print_status "Setting up ECR repositories..."

create_ecr_repo() {
    local repo_name=$1
    if ! aws ecr describe-repositories --repository-names $repo_name --region $AWS_REGION &> /dev/null; then
        aws ecr create-repository --repository-name $repo_name --region $AWS_REGION &> /dev/null
        print_success "Created ECR repository: $repo_name"
    else
        print_success "ECR repository exists: $repo_name"
    fi
}

create_ecr_repo "proj-backend"
create_ecr_repo "proj-frontend"

# Build and push container images
print_status "Building and pushing container images..."

# Login to ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Build and push backend
print_status "Building backend image..."
docker build -t proj-backend:latest ./backend/
docker tag proj-backend:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/proj-backend:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/proj-backend:latest
print_success "Backend image pushed to ECR"

# Build and push frontend
print_status "Building frontend image..."
docker build -t proj-frontend:latest ./frontend/
docker tag proj-frontend:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/proj-frontend:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/proj-frontend:latest
print_success "Frontend image pushed to ECR"

# Create Kubernetes deployment manifests
print_status "Creating Kubernetes deployment manifests..."

cat > k8s-deployment.yaml << EOF
apiVersion: v1
kind: Namespace
metadata:
  name: proj-app
  labels:
    app: proj
    environment: dev
---
apiVersion: v1
kind: Secret
metadata:
  name: proj-secrets
  namespace: proj-app
type: Opaque
stringData:
  database-url: "postgresql://postgres:proj_secure_password_2025@$DATABASE_ENDPOINT:5432/ideas_db"
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: proj-config
  namespace: proj-app
data:
  ENVIRONMENT: "development"
  LOG_LEVEL: "info"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: proj-backend
  namespace: proj-app
  labels:
    app: proj-backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: proj-backend
  template:
    metadata:
      labels:
        app: proj-backend
    spec:
      containers:
      - name: backend
        image: $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/proj-backend:latest
        ports:
        - containerPort: 8000
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: proj-secrets
              key: database-url
        livenessProbe:
          httpGet:
            path: /api/ideas
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /api/ideas
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
---
apiVersion: v1
kind: Service
metadata:
  name: proj-backend-service
  namespace: proj-app
spec:
  selector:
    app: proj-backend
  ports:
  - port: 80
    targetPort: 8000
    protocol: TCP
  type: ClusterIP
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: proj-frontend
  namespace: proj-app
  labels:
    app: proj-frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: proj-frontend
  template:
    metadata:
      labels:
        app: proj-frontend
    spec:
      containers:
      - name: frontend
        image: $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/proj-frontend:latest
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 50m
            memory: 64Mi
          limits:
            cpu: 100m
            memory: 128Mi
---
apiVersion: v1
kind: Service
metadata:
  name: proj-frontend-service
  namespace: proj-app
spec:
  selector:
    app: proj-frontend
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
  type: LoadBalancer
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: proj-ingress
  namespace: proj-app
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
spec:
  rules:
  - http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: proj-backend-service
            port:
              number: 80
      - path: /
        pathType: Prefix
        backend:
          service:
            name: proj-frontend-service
            port:
              number: 80
EOF

# Deploy application to Kubernetes
print_status "Deploying application to Kubernetes..."
kubectl apply -f k8s-deployment.yaml
print_success "Application deployed to Kubernetes"

# Wait for deployments to be ready
print_status "Waiting for application deployments..."
kubectl wait --for=condition=available --timeout=300s deployment/proj-backend -n proj-app
kubectl wait --for=condition=available --timeout=300s deployment/proj-frontend -n proj-app
print_success "Application deployments are ready"

# Get application URL
print_status "Getting application access information..."
sleep 30  # Wait for load balancer

FRONTEND_LB=$(kubectl get service proj-frontend-service -n proj-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "pending")

if [ "$FRONTEND_LB" != "pending" ] && [ -n "$FRONTEND_LB" ]; then
    APP_URL="http://$FRONTEND_LB"
    print_success "Application URL: $APP_URL"
else
    print_warning "Load balancer URL not yet available. Check status with:"
    echo "kubectl get service proj-frontend-service -n proj-app"
fi

# Display summary
echo ""
print_header
print_success "🎉 Deployment completed successfully!"
echo ""
echo "📊 Deployment Summary:"
echo "  🏗️ Infrastructure: Deployed with Cheetah platform"
echo "  ☸️ Kubernetes: EKS cluster with $CLUSTER_NAME"
echo "  🗄️ Database: RDS PostgreSQL at $DATABASE_ENDPOINT"
echo "  🐳 Images: Pushed to ECR repositories"
echo "  🚀 Application: Running in proj-app namespace"
if [ "$FRONTEND_LB" != "pending" ] && [ -n "$FRONTEND_LB" ]; then
    echo "  🌐 URL: $APP_URL"
fi
echo ""
echo "🔧 Useful Commands:"
echo "  kubectl get pods -n proj-app"
echo "  kubectl logs -f deployment/proj-backend -n proj-app"
echo "  kubectl get services -n proj-app"
echo "  kubectl get ingress -n proj-app"
echo ""
echo "🧹 To clean up resources:"
echo "  kubectl delete namespace proj-app"
echo "  terraform destroy -var-file=terraform.tfvars"
echo ""
print_success "Happy coding! 🐆"
