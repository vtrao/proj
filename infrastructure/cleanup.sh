#!/bin/bash

# proj Infrastructure Cleanup Wrapper
# This script leverages the Cheetah platform for infrastructure cleanup
# 
# Usage: ./infrastructure/cleanup.sh [environment] [cloud_provider]
# Example: ./infrastructure/cleanup.sh dev aws

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

print_warning "⚠️  WARNING: This will destroy all proj infrastructure resources!"
print_warning "Environment: $ENVIRONMENT"
print_warning "Cloud Provider: $CLOUD_PROVIDER"
echo
read -p "Are you sure you want to proceed? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    print_status "Cleanup cancelled."
    exit 0
fi

# Check if we're in the right directory
if [ ! -d "$CHEETAH_DIR" ]; then
    print_error "Cheetah submodule not found. Please ensure you're running this from the project root."
    print_error "Expected: ./infrastructure/cleanup.sh"
    exit 1
fi

print_status "🧹 Starting proj infrastructure cleanup using Cheetah platform..."

# Change to cheetah directory and run the cleanup
cd "$CHEETAH_DIR"

# Run the Cheetah cleanup script
print_status "Executing: ./scripts/cleanup.sh $CLOUD_PROVIDER $ENVIRONMENT"
./scripts/cleanup.sh "$CLOUD_PROVIDER" "$ENVIRONMENT"

print_success "✅ proj infrastructure cleanup completed successfully!"
print_success "🎯 All AWS resources have been destroyed."
