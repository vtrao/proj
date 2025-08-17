#!/bin/bash

# proj Infrastructure Deployment Wrapper
# This script leverages the Cheetah platform for infrastructure deployment
# 
# Usage: ./infrastructure/deploy.sh [environment] [cloud_provider]
# Example: ./infrastructure/deploy.sh dev aws

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[PROJ]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[PROJ]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[PROJ]${NC} $1"
}

print_error() {
    echo -e "${RED}[PROJ]${NC} $1"
}

# Default values
ENVIRONMENT=${1:-dev}
CLOUD_PROVIDER=${2:-aws}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHEETAH_DIR="$SCRIPT_DIR/cheetah"

print_status "🚀 Starting proj infrastructure deployment using Cheetah platform"
print_status "Environment: $ENVIRONMENT"
print_status "Cloud Provider: $CLOUD_PROVIDER"

# Check if we're in the right directory
if [ ! -d "$CHEETAH_DIR" ]; then
    print_error "Cheetah submodule not found. Please ensure you're running this from the project root."
    print_error "Expected: ./infrastructure/deploy.sh"
    exit 1
fi

# Check if terraform.tfvars exists and copy to cheetah if needed
if [ -f "$SCRIPT_DIR/terraform/terraform.tfvars" ]; then
    print_status "Using configuration from infrastructure/terraform/terraform.tfvars"
    cp "$SCRIPT_DIR/terraform/terraform.tfvars" "$CHEETAH_DIR/terraform/"
elif [ ! -f "$CHEETAH_DIR/terraform/terraform.tfvars" ]; then
    print_error "Configuration file not found in either location:"
    print_error "  - $SCRIPT_DIR/terraform/terraform.tfvars"
    print_error "  - $CHEETAH_DIR/terraform/terraform.tfvars"
    print_error "Please ensure the proj configuration has been properly set up."
    exit 1
fi

print_status "Configuration validated. Using Cheetah deployment script..."

# Change to cheetah directory and run the deployment
cd "$CHEETAH_DIR"

# Run the Cheetah deployment script (secure deployment if available)
if [ -f "$CHEETAH_DIR/scripts/secure-deploy.sh" ]; then
    print_status "🔐 Using secure deployment with integrated secrets management"
    print_status "Executing: ./scripts/secure-deploy.sh $ENVIRONMENT $CLOUD_PROVIDER proj"
    cd "$CHEETAH_DIR"
    ./scripts/secure-deploy.sh "$ENVIRONMENT" "$CLOUD_PROVIDER" "proj"
else
    print_status "Executing: ./scripts/deploy.sh $CLOUD_PROVIDER $ENVIRONMENT"
    cd "$CHEETAH_DIR"
    ./scripts/deploy.sh "$CLOUD_PROVIDER" "$ENVIRONMENT"
fi

print_success "✅ proj infrastructure deployment completed successfully!"
print_success "🎯 Next steps:"
print_success "   1. Configure kubectl: export KUBECONFIG=terraform/kubeconfig-${CLOUD_PROVIDER}-${ENVIRONMENT}.yaml"
print_success "   2. Verify cluster: kubectl get nodes"
print_success "   3. Deploy your applications to the cluster"
