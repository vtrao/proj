#!/bin/bash

# Proj Application Deployment Script
# Usage: ./deploy.sh [environment] [cloud_provider]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${PURPLE}"
    echo "  ╔═══════════════════════════════════════╗"
    echo "  ║                                       ║"
    echo "  ║           🚀 PROJ DEPLOYMENT          ║"
    echo "  ║         Powered by Cheetah 🐆         ║"
    echo "  ║                                       ║"
    echo "  ╚═══════════════════════════════════════╝"
    echo -e "${NC}"
}

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Default values
ENVIRONMENT=${1:-dev}
CLOUD_PROVIDER=${2:-aws}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

clear
print_header

print_status "🚀 Starting Proj Application deployment..."
print_status "Environment: $ENVIRONMENT"
print_status "Cloud Provider: $CLOUD_PROVIDER"
echo

# Step 1: Deploy infrastructure with Cheetah
print_status "📋 Step 1: Deploying infrastructure with Cheetah..."
cd "$SCRIPT_DIR/cheetah"

if [ ! -f "terraform/terraform.tfvars" ]; then
    print_status "Copying environment configuration..."
    cp "../environments/$ENVIRONMENT/terraform.tfvars" "terraform/terraform.tfvars"
fi

print_status "Deploying Cheetah infrastructure..."
if ./scripts/deploy.sh "$CLOUD_PROVIDER" "$ENVIRONMENT"; then
    print_success "Infrastructure deployed successfully!"
else
    print_error "Infrastructure deployment failed!"
    exit 1
fi

# Step 2: Get infrastructure outputs
print_status "📋 Step 2: Getting infrastructure configuration..."
cd terraform
DATABASE_ENDPOINT=$(terraform output -raw database_endpoint || echo "")
CLUSTER_NAME=$(terraform output -raw cluster_name || echo "")

if [ -z "$DATABASE_ENDPOINT" ]; then
    print_error "Could not get database endpoint from Terraform"
    exit 1
fi

print_success "Database endpoint: $DATABASE_ENDPOINT"
print_success "Cluster name: $CLUSTER_NAME"

# Step 3: Configure kubectl
print_status "📋 Step 3: Configuring kubectl..."
KUBECONFIG_FILE="kubeconfig-$CLOUD_PROVIDER-$ENVIRONMENT.yaml"

if [ -f "$KUBECONFIG_FILE" ]; then
    export KUBECONFIG="$PWD/$KUBECONFIG_FILE"
    print_success "Kubectl configured with: $KUBECONFIG_FILE"
else
    print_error "Kubeconfig file not found: $KUBECONFIG_FILE"
    exit 1
fi

# Step 4: Update database service configuration
print_status "📋 Step 4: Updating database configuration..."
cd "$SCRIPT_DIR/kubernetes/database"

# Create a temporary service file with the actual database endpoint
cp service.yaml service.yaml.bak
sed "s/YOUR_RDS_ENDPOINT/$DATABASE_ENDPOINT/g" service.yaml.bak > service.yaml

print_success "Database service updated with endpoint: $DATABASE_ENDPOINT"

# Step 5: Deploy application to Kubernetes
print_status "📋 Step 5: Deploying application to Kubernetes..."
cd "$SCRIPT_DIR/kubernetes"

# Create namespace
print_status "Creating namespace..."
kubectl apply -f namespace.yaml

# Deploy database configuration
print_status "Deploying database configuration..."
kubectl apply -f database/

# Deploy backend
print_status "Deploying backend..."
kubectl apply -f backend/

# Deploy frontend
print_status "Deploying frontend..."
kubectl apply -f frontend/

# Deploy ingress
print_status "Deploying ingress..."
kubectl apply -f ingress.yaml

print_success "Application deployed successfully!"

# Step 6: Wait for deployments to be ready
print_status "📋 Step 6: Waiting for deployments to be ready..."

print_status "Waiting for backend deployment..."
kubectl wait --for=condition=available --timeout=300s deployment/backend -n proj-app

print_status "Waiting for frontend deployment..."
kubectl wait --for=condition=available --timeout=300s deployment/frontend -n proj-app

print_success "All deployments are ready!"

# Step 7: Show deployment status
print_status "📋 Step 7: Deployment status..."

echo
print_success "🎉 Deployment Summary:"
echo "  Environment: $ENVIRONMENT"
echo "  Cloud Provider: $CLOUD_PROVIDER"
echo "  Cluster: $CLUSTER_NAME"
echo "  Database: $DATABASE_ENDPOINT"
echo

print_status "Pods status:"
kubectl get pods -n proj-app

echo
print_status "Services status:"
kubectl get services -n proj-app

echo
print_status "Ingress status:"
kubectl get ingress -n proj-app

echo
print_success "🚀 Proj application deployed successfully!"
print_status "Next steps:"
echo "  1. Configure your DNS to point to the load balancer"
echo "  2. Set up monitoring and alerting"
echo "  3. Configure CI/CD pipelines for automated deployments"

# Cleanup temporary files
cd "$SCRIPT_DIR/kubernetes/database"
if [ -f "service.yaml.bak" ]; then
    mv service.yaml.bak service.yaml
fi

echo
print_warning "💰 Remember: Cloud resources incur costs. Monitor your usage!"
print_status "To clean up this deployment, run: cd cheetah && ./scripts/cleanup.sh $CLOUD_PROVIDER $ENVIRONMENT"
