# Deprecated Scripts

These scripts have been deprecated in favor of the proper Cheetah platform integration.

## Migration Guide

### Old Way (Deprecated)
```bash
# ❌ Don't use these anymore
./deploy-aws-cheetah.sh
./cleanup-aws.sh
terraform apply -f aws-deployment.tf
```

### New Way (Recommended)
```bash
# ✅ Use Cheetah platform properly
cd infrastructure
./deploy.sh dev aws      # Deploy infrastructure  
./cleanup.sh dev aws     # Cleanup infrastructure
./test-integration.sh    # Run tests
```

## What Changed

1. **Unified Configuration**: All configuration is now in `infrastructure/cheetah/terraform/terraform.tfvars`
2. **Proper Cheetah Integration**: Using Cheetah's built-in deployment scripts instead of custom wrappers
3. **Cleaner Project Structure**: No more scattered scripts in the root directory
4. **Better Documentation**: Comprehensive README in `infrastructure/` directory
5. **Integration Tests**: Proper test suite for infrastructure validation

## Files in This Directory

- `aws-deployment.tf` - Old Terraform configuration (replaced by terraform.tfvars)
- `deploy-aws-cheetah.sh` - Old deployment script (replaced by infrastructure/deploy.sh)
- `cleanup-aws.sh` - Old cleanup script (replaced by infrastructure/cleanup.sh)
- `install-prerequisites.sh` - Old prerequisite installer (replaced by Cheetah's built-in checks)
- `AWS-DEPLOYMENT.md` - Old deployment documentation (replaced by infrastructure/README.md)

## Migration Complete

All functionality has been migrated to the proper Cheetah platform integration. These files are kept for reference only and will be removed in a future version.

---

**Use `cd infrastructure && ./deploy.sh dev aws` instead! 🚀**
