#!/bin/bash

# Safe migration approach - test new deployment first, then migrate
# This script validates the new Cheetah approach without touching existing infrastructure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[TEST]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[TEST]${NC} $1"
}

print_error() {
    echo -e "${RED}[TEST]${NC} $1"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_status "🧪 Testing Cheetah deployment approach (dry run)..."

cd "$SCRIPT_DIR/cheetah/terraform"

# Test terraform plan to see what would be created
print_status "Running terraform plan to preview new infrastructure..."
terraform init -upgrade

print_status "Planning new infrastructure..."
terraform plan -var-file="terraform.tfvars" -out=test.tfplan

print_success "✅ Terraform plan completed successfully!"
print_status "📋 Review the plan above to see what resources will be created."
print_warning "⚠️  Note: This is just a test plan - no resources were created."

# Clean up test plan
rm -f test.tfplan

print_status "🔍 Comparing with existing infrastructure..."
cd ../../..

if [ -f "terraform.tfstate" ]; then
    print_warning "📊 Existing infrastructure found:"
    terraform show terraform.tfstate | grep "resource \"" | sort | uniq -c
    echo
    print_status "💡 Next steps:"
    print_status "  1. Review the terraform plan output above"
    print_status "  2. If satisfied, run the migration script:"
    print_status "     ./infrastructure/migrate-to-cheetah.sh"
    print_status "  3. Or manually cleanup and deploy:"
    print_status "     terraform destroy  # cleanup old"
    print_status "     cd infrastructure && ./deploy.sh dev aws  # deploy new"
else
    print_success "🆕 No existing infrastructure found - safe to proceed!"
    print_status "💡 You can now deploy directly:"
    print_status "     cd infrastructure && ./deploy.sh dev aws"
fi
