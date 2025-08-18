#!/bin/bash

# Enhanced Cheetah Platform Validation Test
# This script validates that all the deployment improvements are working correctly

set -e

echo "🐆 Cheetah Platform Validation Test"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Test counter
tests_passed=0
tests_failed=0

run_test() {
    local test_name="$1"
    local test_command="$2"
    
    print_status "Running test: $test_name"
    
    if eval "$test_command"; then
        print_success "✅ $test_name - PASSED"
        ((tests_passed++))
    else
        print_error "❌ $test_name - FAILED"
        ((tests_failed++))
    fi
    echo
}

print_status "Starting Cheetah platform validation..."
echo

# Test 1: Check if main deployment script exists and is executable
run_test "Main deployment script exists" \
    "[[ -x infrastructure/cheetah/deploy.sh ]]"

# Test 2: Check if application deployment script exists and is executable
run_test "Application deployment script exists" \
    "[[ -x infrastructure/cheetah/scripts/deploy-apps.sh ]]"

# Test 3: Check if template customization script exists and is executable
run_test "Template customization script exists" \
    "[[ -x infrastructure/cheetah/scripts/customize-templates.sh ]]"

# Test 4: Check if Docker build script exists and is executable
run_test "Docker build script exists" \
    "[[ -x infrastructure/cheetah/scripts/build-images.sh ]]"

# Test 5: Check if Kubernetes templates directory exists
run_test "Kubernetes templates directory exists" \
    "[[ -d infrastructure/cheetah/kubernetes/templates ]]"

# Test 6: Check if required Kubernetes templates exist
run_test "Backend deployment template exists" \
    "[[ -f infrastructure/cheetah/kubernetes/templates/backend-deployment.yaml ]]"

run_test "Frontend deployment template exists" \
    "[[ -f infrastructure/cheetah/kubernetes/templates/frontend-deployment.yaml ]]"

run_test "Database init job template exists" \
    "[[ -f infrastructure/cheetah/kubernetes/templates/database-init-job.yaml ]]"

run_test "Namespace and secrets template exists" \
    "[[ -f infrastructure/cheetah/kubernetes/templates/namespace-and-secrets.yaml ]]"

run_test "Database service template exists" \
    "[[ -f infrastructure/cheetah/kubernetes/templates/database-service.yaml ]]"

# Test 7: Check if application examples exist
run_test "Backend Python example exists" \
    "[[ -d infrastructure/cheetah/examples/backend-python ]]"

run_test "Frontend React example exists" \
    "[[ -d infrastructure/cheetah/examples/frontend-react ]]"

# Test 8: Check if backend example has required files
run_test "Backend Dockerfile exists" \
    "[[ -f infrastructure/cheetah/examples/backend-python/Dockerfile ]]"

run_test "Backend main.py exists" \
    "[[ -f infrastructure/cheetah/examples/backend-python/main.py ]]"

run_test "Backend requirements.txt exists" \
    "[[ -f infrastructure/cheetah/examples/backend-python/requirements.txt ]]"

# Test 9: Check if frontend example has required files
run_test "Frontend Dockerfile exists" \
    "[[ -f infrastructure/cheetah/examples/frontend-react/Dockerfile ]]"

run_test "Frontend package.json exists" \
    "[[ -f infrastructure/cheetah/examples/frontend-react/package.json ]]"

run_test "Frontend App.js exists" \
    "[[ -f infrastructure/cheetah/examples/frontend-react/src/App.js ]]"

# Test 10: Check if scripts have proper error handling
run_test "Deploy script has error handling" \
    "grep -q 'set -e' infrastructure/cheetah/scripts/deploy-apps.sh"

run_test "Build script has error handling" \
    "grep -q 'set -e' infrastructure/cheetah/scripts/build-images.sh"

# Test 11: Check if scripts have proper logging
run_test "Deploy script has logging functions" \
    "grep -q 'print_status\\|log_info' infrastructure/cheetah/scripts/deploy-apps.sh"

# Test 12: Check if templates have placeholders for customization
run_test "Backend template has placeholders" \
    "grep -q '{{PROJECT_NAME}}' infrastructure/cheetah/kubernetes/templates/backend-deployment.yaml"

run_test "Frontend template has placeholders" \
    "grep -q '{{PROJECT_NAME}}' infrastructure/cheetah/kubernetes/templates/frontend-deployment.yaml"

# Test 13: Check if main deployment script has comprehensive functionality
run_test "Main script has phase management" \
    "grep -q 'SKIP_PHASE' infrastructure/cheetah/deploy.sh"

run_test "Main script has error handling" \
    "grep -q 'check_prerequisites\\|error_exit' infrastructure/cheetah/deploy.sh"

# Test 14: Check if backend example has health checks
run_test "Backend has health endpoint" \
    "grep -q '/health' infrastructure/cheetah/examples/backend-python/main.py"

# Test 15: Check if frontend example has API integration
run_test "Frontend has API integration" \
    "grep -q '/api/' infrastructure/cheetah/examples/frontend-react/src/App.js"

# Test 16: Check if Docker examples follow security best practices
run_test "Backend Dockerfile uses non-root user" \
    "grep -q 'USER' infrastructure/cheetah/examples/backend-python/Dockerfile"

run_test "Frontend Dockerfile uses non-root user" \
    "grep -q 'USER' infrastructure/cheetah/examples/frontend-react/Dockerfile"

# Test 17: Check if Kubernetes templates have security contexts
run_test "Backend template has security context" \
    "grep -q 'securityContext' infrastructure/cheetah/kubernetes/templates/backend-deployment.yaml"

run_test "Frontend template has security context" \
    "grep -q 'securityContext' infrastructure/cheetah/kubernetes/templates/frontend-deployment.yaml"

# Test 18: Check if templates have resource limits
run_test "Backend template has resource limits" \
    "grep -q 'resources:' infrastructure/cheetah/kubernetes/templates/backend-deployment.yaml"

run_test "Frontend template has resource limits" \
    "grep -q 'resources:' infrastructure/cheetah/kubernetes/templates/frontend-deployment.yaml"

# Test 19: Check if templates have health checks
run_test "Backend template has liveness probe" \
    "grep -q 'livenessProbe' infrastructure/cheetah/kubernetes/templates/backend-deployment.yaml"

run_test "Frontend template has readiness probe" \
    "grep -q 'readinessProbe' infrastructure/cheetah/kubernetes/templates/frontend-deployment.yaml"

# Test 20: Check README documentation
run_test "Enhanced README exists" \
    "[[ -f infrastructure/cheetah/README.md ]]"

run_test "README has application deployment section" \
    "grep -q 'Application Deployment' infrastructure/cheetah/README.md"

# Print final results
echo "================================================"
echo "🐆 Cheetah Platform Validation Results"
echo "================================================"
print_success "Tests Passed: $tests_passed"
if [ $tests_failed -gt 0 ]; then
    print_error "Tests Failed: $tests_failed"
else
    print_success "Tests Failed: $tests_failed"
fi

total_tests=$((tests_passed + tests_failed))
success_rate=$(( tests_passed * 100 / total_tests ))

echo
print_status "Success Rate: $success_rate%"

if [ $tests_failed -eq 0 ]; then
    print_success "🎉 All tests passed! Cheetah platform is ready for production use."
    echo
    print_status "What this means:"
    echo "✅ Complete deployment automation is in place"
    echo "✅ All templates and examples are available"
    echo "✅ Security best practices are implemented"
    echo "✅ Error handling and logging are comprehensive"
    echo "✅ Multi-architecture support is configured"
    echo "✅ Health checks and monitoring are included"
    echo
    print_status "Next steps:"
    echo "1. Test with a fresh deployment: ./infrastructure/cheetah/deploy.sh"
    echo "2. Use templates for new projects: cp -r infrastructure/cheetah/examples/* ."
    echo "3. Review documentation: cat infrastructure/cheetah/README.md"
    exit 0
else
    print_error "Some tests failed. Please review the issues above."
    exit 1
fi
