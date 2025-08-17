#!/bin/bash

# Cleanup script for proj AWS deployment using Cheetah platform

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}🐆 [CLEANUP]${NC} $1"
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

AWS_REGION="us-east-1"

print_status "Starting cleanup of proj AWS resources..."

# Check if kubectl is available and cluster is accessible
if command -v kubectl &> /dev/null; then
    if kubectl cluster-info &> /dev/null; then
        print_status "Removing Kubernetes application..."
        kubectl delete namespace proj-app --ignore-not-found=true
        print_success "Kubernetes application removed"
    else
        print_warning "Kubernetes cluster not accessible, skipping app cleanup"
    fi
else
    print_warning "kubectl not found, skipping Kubernetes cleanup"
fi

# Remove ECR repositories
if command -v aws &> /dev/null; then
    print_status "Cleaning up ECR repositories..."
    
    for repo in "proj-backend" "proj-frontend"; do
        if aws ecr describe-repositories --repository-names $repo --region $AWS_REGION &> /dev/null; then
            # Delete all images first
            aws ecr list-images --repository-name $repo --region $AWS_REGION --query 'imageIds[*]' --output json | \
            jq '.[] | select(.imageTag != null) | {imageTag: .imageTag}' | \
            xargs -I {} aws ecr batch-delete-image --repository-name $repo --region $AWS_REGION --image-ids '{}' &> /dev/null || true
            
            # Delete repository
            aws ecr delete-repository --repository-name $repo --region $AWS_REGION --force &> /dev/null
            print_success "Removed ECR repository: $repo"
        fi
    done
fi

# Destroy Terraform infrastructure
if [ -f "terraform.tfstate" ] || [ -d ".terraform" ]; then
    print_status "Destroying Terraform infrastructure..."
    
    # Ask for confirmation
    print_warning "This will destroy all AWS infrastructure created by Terraform."
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        terraform destroy -var-file=terraform.tfvars -auto-approve
        print_success "Infrastructure destroyed"
    else
        print_status "Infrastructure destruction cancelled"
    fi
else
    print_warning "No Terraform state found, skipping infrastructure cleanup"
fi

# Clean up local files
print_status "Cleaning up local deployment files..."
rm -f k8s-deployment.yaml
rm -f tfplan
print_success "Local files cleaned up"

echo ""
print_success "🎉 Cleanup completed!"
echo ""
echo "📋 What was cleaned up:"
echo "  • Kubernetes application (proj-app namespace)"
echo "  • ECR repositories (proj-backend, proj-frontend)"  
echo "  • AWS infrastructure (EKS, RDS, VPC, etc.)"
echo "  • Local deployment files"
echo ""
print_status "All proj AWS resources have been removed. 🐆"
