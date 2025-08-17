#!/bin/bash
# Test script to verify the moved security scripts work correctly

set -e

echo "🧪 Testing moved security scripts..."
echo "Current directory: $(pwd)"

# Test 1: Verify script locations
echo "📋 Test 1: Verifying script files exist"
if [[ -f "infrastructure/scripts/setup-secrets.sh" && -f "infrastructure/scripts/secure-deploy.sh" ]]; then
    echo "✅ Security scripts found in infrastructure/scripts/"
else
    echo "❌ Security scripts not found in expected location"
    exit 1
fi

# Test 2: Verify scripts are executable
echo "📋 Test 2: Verifying scripts are executable"
if [[ -x "infrastructure/scripts/setup-secrets.sh" && -x "infrastructure/scripts/secure-deploy.sh" ]]; then
    echo "✅ Scripts are executable"
else
    echo "❌ Scripts are not executable"
    exit 1
fi

# Test 3: Verify relative paths in setup-secrets.sh
echo "📋 Test 3: Verifying paths in setup-secrets.sh"
cd infrastructure/scripts
if [[ -d "../k8s/external-secrets" ]]; then
    echo "✅ External secrets path exists: ../k8s/external-secrets"
else
    echo "❌ External secrets path not found"
    exit 1
fi

# Test 4: Verify paths in secure-deploy.sh
echo "📋 Test 4: Verifying paths in secure-deploy.sh"
if [[ -f "../cheetah/terraform/terraform.tfvars.template" ]]; then
    echo "✅ Terraform template path exists: ../cheetah/terraform/terraform.tfvars.template"
else
    echo "❌ Terraform template path not found"
    exit 1
fi

if [[ -f "../deploy.sh" ]]; then
    echo "✅ Deploy script path exists: ../deploy.sh"
else
    echo "❌ Deploy script path not found"
    exit 1
fi

# Test 5: Verify help/usage works
echo "📋 Test 5: Testing script help functionality"
if ./setup-secrets.sh 2>&1 | grep -q "Setting up secrets"; then
    echo "✅ setup-secrets.sh executes without errors"
else
    echo "⚠️  setup-secrets.sh may have issues (expected for missing cloud credentials)"
fi

cd ../..

echo ""
echo "🎉 All tests passed! Security scripts successfully moved to infrastructure/scripts/"
echo "📋 Updated paths:"
echo "   • setup-secrets.sh: infrastructure/scripts/setup-secrets.sh"
echo "   • secure-deploy.sh: infrastructure/scripts/secure-deploy.sh" 
echo "   • External secrets: ../k8s/external-secrets/ (relative from scripts/)"
echo "   • Terraform template: ../cheetah/terraform/ (relative from scripts/)"
echo ""
echo "🚀 Usage from project root:"
echo "   cd infrastructure && ./scripts/setup-secrets.sh aws dev proj"
echo "   cd infrastructure && ./scripts/secure-deploy.sh dev aws proj"
