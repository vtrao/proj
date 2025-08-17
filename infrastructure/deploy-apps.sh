#!/bin/bash

# Application Deployment Script for Kubernetes
# This script deploys the initial Kubernetes manifests after infrastructure is ready
# Usage: ./deploy-apps.sh [environment] [cloud_provider]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[APPS]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[APPS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[APPS]${NC} $1"
}

print_error() {
    echo -e "${RED}[APPS]${NC} $1"
}

ENVIRONMENT=${1:-dev}
CLOUD_PROVIDER=${2:-aws}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

print_status "🚀 Deploying proj applications to Kubernetes..."
print_status "Environment: $ENVIRONMENT"
print_status "Cloud Provider: $CLOUD_PROVIDER"

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Set kubeconfig from Cheetah deployment
KUBECONFIG_FILE="$SCRIPT_DIR/cheetah/terraform/kubeconfig-$CLOUD_PROVIDER-$ENVIRONMENT.yaml"

if [ ! -f "$KUBECONFIG_FILE" ]; then
    print_error "Kubeconfig not found: $KUBECONFIG_FILE"
    print_error "Please run infrastructure deployment first: ./deploy.sh $ENVIRONMENT $CLOUD_PROVIDER"
    exit 1
fi

export KUBECONFIG="$KUBECONFIG_FILE"
print_success "Using kubeconfig: $KUBECONFIG_FILE"

# Verify cluster connectivity
if ! kubectl cluster-info > /dev/null 2>&1; then
    print_error "Cannot connect to Kubernetes cluster"
    print_error "Please ensure the cluster is running and kubeconfig is correct"
    exit 1
fi

print_success "✅ Connected to Kubernetes cluster"

# Deploy applications
print_status "Deploying application manifests..."

# Deploy in order: namespace, secrets, configs, apps, services, ingress
DEPLOY_ORDER=(
    "kubernetes/namespace.yaml"
    "kubernetes/database/"
    "kubernetes/backend/"
    "kubernetes/frontend/"
    "kubernetes/ingress.yaml"
)

for manifest in "${DEPLOY_ORDER[@]}"; do
    if [ -f "$SCRIPT_DIR/$manifest" ] || [ -d "$SCRIPT_DIR/$manifest" ]; then
        print_status "Applying $manifest..."
        if kubectl apply -f "$SCRIPT_DIR/$manifest"; then
            print_success "✅ Applied $manifest"
        else
            print_error "❌ Failed to apply $manifest"
            exit 1
        fi
    else
        print_warning "⚠️  $manifest not found, skipping..."
    fi
done

# Wait for deployments to be ready
print_status "Waiting for deployments to be ready..."

# Check if deployments exist and wait for them
if kubectl get deployment backend -n proj-app > /dev/null 2>&1; then
    print_status "Waiting for backend deployment..."
    kubectl rollout status deployment/backend -n proj-app --timeout=300s
    print_success "✅ Backend deployment ready"
fi

if kubectl get deployment frontend -n proj-app > /dev/null 2>&1; then
    print_status "Waiting for frontend deployment..."
    kubectl rollout status deployment/frontend -n proj-app --timeout=300s
    print_success "✅ Frontend deployment ready"
fi

# Show deployment status
print_status "📊 Deployment Status:"
echo
kubectl get pods -n proj-app
echo
kubectl get services -n proj-app
echo

print_success "🎉 Application deployment completed successfully!"
print_status "Next steps:"
echo "  1. Check application logs: kubectl logs -f deployment/backend -n proj-app"
echo "  2. Test connectivity: kubectl port-forward svc/frontend-service 8080:80 -n proj-app"
echo "  3. Access application: http://localhost:8080"

# Show ingress info if available
if kubectl get ingress -n proj-app > /dev/null 2>&1; then
    echo
    print_status "🌐 Ingress Information:"
    kubectl get ingress -n proj-app
fi
