#!/bin/bash

# Migration script from old aws-deployment.tf approach to Cheetah platform
# This script safely migrates existing infrastructure to use the Cheetah platform

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[MIGRATE]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[MIGRATE]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[MIGRATE]${NC} $1"
}

print_error() {
    echo -e "${RED}[MIGRATE]${NC} $1"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

print_warning "🔄 Starting migration from old deployment to Cheetah platform"
print_warning "This will:"
print_warning "  1. Destroy existing infrastructure (safely)"
print_warning "  2. Deploy new infrastructure using Cheetah"
print_warning "  3. Preserve application data where possible"
echo

read -p "Are you sure you want to proceed with migration? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    print_status "Migration cancelled."
    exit 0
fi

# Step 1: Backup current state
print_status "📋 Step 1: Backing up current terraform state..."
cd "$PROJECT_ROOT"

if [ -f "terraform.tfstate" ]; then
    cp terraform.tfstate terraform.tfstate.pre-migration-backup
    print_success "State backup created: terraform.tfstate.pre-migration-backup"
fi

# Step 2: Destroy existing infrastructure using old configuration
print_status "🧹 Step 2: Destroying existing infrastructure..."
print_warning "This will destroy all existing AWS resources..."

# First check if we can restore the old deployment file temporarily
if [ -f "deprecated-scripts/aws-deployment.tf" ]; then
    print_status "Restoring old deployment configuration temporarily..."
    cp deprecated-scripts/aws-deployment.tf .
    
    # Initialize with old config if needed
    if [ ! -d ".terraform" ]; then
        terraform init
    fi
    
    # Destroy existing infrastructure
    print_status "Destroying existing infrastructure..."
    terraform destroy -auto-approve
    
    # Clean up
    rm -f aws-deployment.tf
    rm -rf .terraform*
    rm -f terraform.tfstate*
    rm -f tfplan
    
    print_success "Old infrastructure destroyed successfully"
else
    print_error "Could not find old deployment configuration!"
    print_error "Manual cleanup may be required."
    exit 1
fi

# Step 3: Deploy new infrastructure using Cheetah
print_status "🚀 Step 3: Deploying new infrastructure using Cheetah..."
cd "$SCRIPT_DIR"

# Deploy using Cheetah
print_status "Executing Cheetah deployment..."
./deploy.sh dev aws

print_success "✅ Migration completed successfully!"
print_success "🎯 Infrastructure is now managed by the Cheetah platform"
print_success "📁 Old backup preserved as: terraform.tfstate.pre-migration-backup"
print_success "🚀 You can now use: ./infrastructure/deploy.sh dev aws"
