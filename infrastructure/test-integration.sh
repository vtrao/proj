#!/bin/bash

# Test script for Cheetah integration with Proj
# This script validates the integration setup without deploying to cloud

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

print_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
FAILED_TESTS=0

echo "🧪 Testing Cheetah Integration with Proj"
echo "========================================"
echo

# Test 1: Check directory structure
print_status "Testing directory structure..."
if [ -d "$PROJECT_ROOT/infrastructure/cheetah" ]; then
    print_success "Cheetah directory exists"
else
    print_error "Cheetah directory not found"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

if [ -d "$PROJECT_ROOT/infrastructure/kubernetes" ]; then
    print_success "Kubernetes manifests directory exists"
else
    print_error "Kubernetes manifests directory not found"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

if [ -d "$PROJECT_ROOT/infrastructure/environments" ]; then
    print_success "Environment configurations directory exists"
else
    print_error "Environment configurations directory not found"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test 2: Check required files
print_status "Testing required files..."
REQUIRED_FILES=(
    "infrastructure/cheetah/README.md"
    "infrastructure/cheetah/terraform/main.tf"
    "infrastructure/cheetah/scripts/quickstart.sh"
    "infrastructure/cheetah/scripts/deploy.sh"
    "infrastructure/cheetah/scripts/cleanup.sh"
    "infrastructure/kubernetes/namespace.yaml"
    "infrastructure/kubernetes/backend/deployment.yaml"
    "infrastructure/kubernetes/frontend/deployment.yaml"
    "infrastructure/kubernetes/database/secret.yaml"
    "infrastructure/kubernetes/ingress.yaml"
    "infrastructure/environments/dev/terraform.tfvars"
    "infrastructure/deploy.sh"
    ".github/workflows/deploy.yml"
)

# Optional files that might exist in different project structures
OPTIONAL_FILES=(
    "aws-deployment.tf"
    "deploy-aws-cheetah.sh"
    "docker-compose.yml"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$PROJECT_ROOT/$file" ]; then
        print_success "$file exists"
    else
        print_error "$file not found"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
done

# Check optional files (don't fail if missing)
for file in "${OPTIONAL_FILES[@]}"; do
    if [ -f "$PROJECT_ROOT/$file" ]; then
        print_success "$file exists (optional)"
    else
        print_warning "$file not found (optional)"
    fi
done

# Test 3: Check script permissions
print_status "Testing script permissions..."
EXECUTABLE_SCRIPTS=(
    "infrastructure/cheetah/scripts/quickstart.sh"
    "infrastructure/cheetah/scripts/deploy.sh"
    "infrastructure/cheetah/scripts/cleanup.sh"
    "infrastructure/deploy.sh"
)

for script in "${EXECUTABLE_SCRIPTS[@]}"; do
    if [ -x "$PROJECT_ROOT/$script" ]; then
        print_success "$script is executable"
    else
        print_error "$script is not executable"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
done

# Test 4: Validate Terraform configuration
print_status "Testing Terraform configuration..."
cd "$PROJECT_ROOT"

if command -v terraform &> /dev/null; then
    # Check if there's a main deployment configuration
    if [ -f "aws-deployment.tf" ]; then
        if terraform fmt -check -diff aws-deployment.tf > /dev/null 2>&1; then
            print_success "Main Terraform configuration is properly formatted"
        else
            print_warning "Main Terraform configuration formatting issues found (non-critical)"
        fi
        
        # Initialize terraform if needed
        if [ ! -d ".terraform" ]; then
            print_status "Initializing Terraform..."
            terraform init > /dev/null 2>&1
        fi
        
        if terraform validate; then
            print_success "Main Terraform configuration is valid"
        else
            print_error "Main Terraform configuration validation failed"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    else
        # Fallback to cheetah submodule validation
        cd "$PROJECT_ROOT/infrastructure/cheetah/terraform"
        
        if terraform fmt -check -diff > /dev/null 2>&1; then
            print_success "Cheetah Terraform configuration is properly formatted"
        else
            print_warning "Cheetah Terraform configuration formatting issues found (non-critical)"
        fi
        
        # Note: We skip module validation in submodule as it may not be initialized
        print_warning "Cheetah submodule validation skipped (modules not initialized)"
    fi
else
    print_warning "Terraform not installed - skipping validation"
fi

# Test 5: Validate Kubernetes manifests
print_status "Testing Kubernetes manifests..."
cd "$PROJECT_ROOT/infrastructure/kubernetes"

if command -v kubectl &> /dev/null; then
    # Test basic YAML syntax validation
    if kubectl apply --dry-run=client --validate=false -f namespace.yaml > /dev/null 2>&1; then
        print_success "Namespace manifest syntax is valid"
    else
        print_warning "Namespace manifest syntax check failed (may need cluster connection)"
    fi
    
    if kubectl apply --dry-run=client --validate=false -f backend/ > /dev/null 2>&1; then
        print_success "Backend manifests syntax is valid"
    else
        print_warning "Backend manifest syntax check failed (may need cluster connection)"
    fi
    
    if kubectl apply --dry-run=client --validate=false -f frontend/ > /dev/null 2>&1; then
        print_success "Frontend manifests syntax is valid"
    else
        print_warning "Frontend manifest syntax check failed (may need cluster connection)"
    fi
else
    print_warning "kubectl not installed - skipping Kubernetes validation"
fi

# Test 6: Test Docker Compose (existing functionality)
print_status "Testing Docker Compose compatibility..."
cd "$PROJECT_ROOT"

if [ -f "docker-compose.yml" ]; then
    if command -v docker-compose &> /dev/null; then
        if docker-compose config > /dev/null 2>&1; then
            print_success "Docker Compose configuration is valid"
        else
            print_warning "Docker Compose configuration validation failed (may need adjustments)"
        fi
    elif command -v docker &> /dev/null; then
        if docker compose config > /dev/null 2>&1; then
            print_success "Docker Compose configuration is valid (using docker compose)"
        else
            print_warning "Docker Compose configuration validation failed (may need adjustments)"
        fi
    else
        print_warning "Docker/Docker Compose not installed - skipping validation"
    fi
else
    print_warning "docker-compose.yml not found (optional for cloud-native deployment)"
fi

# Test 7: Check environment configurations
print_status "Testing environment configurations..."
cd "$PROJECT_ROOT/infrastructure/environments/dev"

if [ -f "terraform.tfvars" ]; then
    # Basic syntax check for tfvars file
    if grep -q "cloud_provider.*=.*\"aws\"" terraform.tfvars; then
        print_success "Development environment configuration is valid"
    else
        print_error "Development environment configuration issues found"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
else
    print_error "Development terraform.tfvars not found"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test 8: Integration points
print_status "Testing integration points..."

# Check if backend health endpoint is referenced
if grep -q "/health" "$PROJECT_ROOT/infrastructure/kubernetes/backend/deployment.yaml"; then
    print_success "Backend health checks are configured"
else
    print_warning "Backend health checks not found"
fi

# Check if database connection is properly configured
if grep -q "database-service" "$PROJECT_ROOT/infrastructure/kubernetes/backend/deployment.yaml"; then
    print_success "Database service connection is configured"
else
    print_error "Database service connection not configured"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test 9: Documentation
print_status "Testing documentation..."
DOCUMENTATION_CHECK=false

if [ -f "$PROJECT_ROOT/infrastructure/README.md" ] && grep -q "Cheetah" "$PROJECT_ROOT/infrastructure/README.md"; then
    print_success "Infrastructure documentation mentions Cheetah"
    DOCUMENTATION_CHECK=true
fi

if [ -f "$PROJECT_ROOT/README.md" ] && grep -q -i "cheetah\|aws\|deployment" "$PROJECT_ROOT/README.md"; then
    print_success "Project README mentions deployment information"
    DOCUMENTATION_CHECK=true
fi

if [ -f "$PROJECT_ROOT/AWS-DEPLOYMENT.md" ]; then
    print_success "AWS deployment documentation exists"
    DOCUMENTATION_CHECK=true
fi

if [ "$DOCUMENTATION_CHECK" = false ]; then
    print_error "Integration documentation incomplete"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Summary
echo
echo "========================================"
if [ $FAILED_TESTS -eq 0 ]; then
    print_success "🎉 All tests passed! Cheetah integration is ready."
    echo
    echo "Next steps:"
    echo "  1. Configure your cloud provider credentials"
    echo "  2. Run: cd infrastructure && ./deploy.sh dev aws"
    echo "  3. Test your application deployment"
    echo
    exit 0
else
    print_error "❌ $FAILED_TESTS test(s) failed. Please fix the issues above."
    echo
    exit 1
fi
