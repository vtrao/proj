#!/bin/bash

# Installation script for AWS deployment prerequisites

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}📦 [INSTALL]${NC} $1"
}

print_success() {
    echo -e "${GREEN}✅ [SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}❌ [ERROR]${NC} $1"
}

echo -e "${BLUE}"
echo "=================================================="
echo "🐆 Cheetah Platform - Prerequisites Installation"
echo "=================================================="
echo -e "${NC}"

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    print_status "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    print_success "Homebrew installed"
else
    print_success "Homebrew already installed"
fi

# Install Terraform
if ! command -v terraform &> /dev/null; then
    print_status "Installing Terraform..."
    brew install terraform
    print_success "Terraform installed"
else
    print_success "Terraform already installed"
fi

# Install AWS CLI
if ! command -v aws &> /dev/null; then
    print_status "Installing AWS CLI..."
    curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
    sudo installer -pkg AWSCLIV2.pkg -target /
    rm AWSCLIV2.pkg
    print_success "AWS CLI installed"
else
    print_success "AWS CLI already installed"
fi

# Check kubectl (should already be available)
if command -v kubectl &> /dev/null; then
    print_success "kubectl already installed"
else
    print_status "Installing kubectl..."
    brew install kubectl
    print_success "kubectl installed"
fi

# Check Docker
if command -v docker &> /dev/null; then
    print_success "Docker already installed"
else
    print_error "Docker not found. Please install Docker Desktop manually:"
    echo "https://www.docker.com/products/docker-desktop"
fi

# Verify installations
echo ""
print_status "Verifying installations..."
terraform version
aws --version
kubectl version --client=true
docker --version

echo ""
print_success "🎉 All prerequisites installed!"
echo ""
echo "Next steps:"
echo "1. Configure AWS credentials: aws configure"
echo "2. Start Docker Desktop"
echo "3. Run deployment: ./deploy-aws-cheetah.sh"
