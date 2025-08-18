# Deprecated AWS Infrastructure Files

⚠️ **DEPRECATED**: These files have been replaced by the Cheetah platform integration.

## Files in this directory:

- **`aws-deployment.tf`** - Legacy AWS infrastructure Terraform configuration
- **`deploy-aws.tf`** - Old AWS deployment Terraform setup  
- **`terraform.tfvars`** - Legacy Terraform variables configuration
- **`multi-stage-Dockerfile`** - Old multi-stage Docker build approach

## Migration Status

✅ **MIGRATED TO**: Cheetah platform (`../cheetah/`) provides:
- Cloud-agnostic infrastructure
- Improved deployment automation
- Enhanced security features
- Better cost optimization
- Multi-cloud support (AWS + Azure)

## Current Usage

**Instead of these files, use:**
```bash
# Deploy using Cheetah platform
./infrastructure/deploy.sh dev aws

# Or for Azure
./infrastructure/deploy.sh dev azure
```

## Why Deprecated

1. **Single Cloud Limitation**: These files only supported AWS
2. **Manual Configuration**: Required extensive manual setup
3. **No Cost Optimization**: Lacked free-tier optimizations
4. **Limited Security**: Basic security configurations only
5. **Maintenance Overhead**: Required individual maintenance for each cloud

## Historical Context

These files represent the initial AWS deployment approach before:
- Cheetah platform adoption (Phase 2)
- Multi-cloud evolution (Phase 3)  
- Enterprise CI/CD implementation (Phase 4)
- Security enhancement program (Phase 4)

For complete project history, see: [`../../PROJECT_DEVELOPMENT_JOURNEY.md`](../../PROJECT_DEVELOPMENT_JOURNEY.md)
