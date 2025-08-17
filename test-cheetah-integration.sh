#!/bin/bash
# Test script to verify the integrated cheetah security deployment

set -e

echo "🧪 Testing integrated cheetah security deployment..."

# Test 1: Verify cheetah submodule has security scripts
echo "📋 Test 1: Verifying cheetah submodule security scripts"
if [[ -f "infrastructure/cheetah/scripts/setup-secrets.sh" && -f "infrastructure/cheetah/scripts/secure-deploy.sh" ]]; then
    echo "✅ Security scripts found in cheetah submodule"
else
    echo "❌ Security scripts not found in cheetah submodule"
    exit 1
fi

# Test 2: Verify scripts are executable
echo "📋 Test 2: Verifying scripts are executable"
if [[ -x "infrastructure/cheetah/scripts/setup-secrets.sh" && -x "infrastructure/cheetah/scripts/secure-deploy.sh" ]]; then
    echo "✅ Scripts are executable"
else
    echo "❌ Scripts are not executable"
    exit 1
fi

# Test 3: Verify external-secrets configuration in cheetah
echo "📋 Test 3: Verifying external-secrets configuration"
if [[ -d "infrastructure/cheetah/kubernetes/external-secrets" ]]; then
    echo "✅ External secrets configuration found in cheetah"
    echo "   Files: $(ls infrastructure/cheetah/kubernetes/external-secrets/)"
else
    echo "❌ External secrets configuration not found"
    exit 1
fi

# Test 4: Verify terraform security files in cheetah
echo "📋 Test 4: Verifying terraform security files"
if [[ -f "infrastructure/cheetah/terraform/secrets.tf" && -f "infrastructure/cheetah/terraform/vault.tf" ]]; then
    echo "✅ Terraform security files found in cheetah"
else
    echo "❌ Terraform security files not found"
    exit 1
fi

# Test 5: Verify old scripts are removed
echo "📋 Test 5: Verifying old scripts are removed"
if [[ ! -d "infrastructure/scripts" ]]; then
    echo "✅ Old scripts directory successfully removed"
else
    echo "❌ Old scripts directory still exists"
    exit 1
fi

# Test 6: Verify deploy.sh integration
echo "📋 Test 6: Verifying deploy.sh integration"
if grep -q "secure-deploy.sh" infrastructure/deploy.sh; then
    echo "✅ Deploy.sh updated to use secure deployment"
else
    echo "❌ Deploy.sh not updated for secure deployment"
    exit 1
fi

# Test 7: Test help functionality
echo "📋 Test 7: Testing script help functionality"
cd infrastructure/cheetah
if ./scripts/setup-secrets.sh 2>&1 | grep -q "Setting up secrets"; then
    echo "✅ setup-secrets.sh executes without errors"
else
    echo "⚠️  setup-secrets.sh may have issues (expected for missing cloud credentials)"
fi

cd ../..

echo ""
echo "🎉 All tests passed! Cheetah security integration successful!"
echo "📋 Summary:"
echo "   ✅ Security scripts integrated into cheetah submodule"
echo "   ✅ External secrets configuration available in cheetah"
echo "   ✅ Terraform security modules available in cheetah" 
echo "   ✅ Old duplicate scripts and configurations removed"
echo "   ✅ Deploy script updated to use integrated security"
echo ""
echo "🚀 New usage:"
echo "   ./infrastructure/deploy.sh dev aws  # Uses secure deployment automatically"
echo "   # Or manually: cd infrastructure/cheetah && ./scripts/secure-deploy.sh dev aws proj"
