# Deprecated Scripts

This directory contains deployment and cleanup scripts that have been replaced by the Cheetah platform integration.

## Scripts in this directory:

### Deployment Scripts
- **`deploy-aws-cheetah.sh`** - Legacy AWS deployment with early Cheetah integration
- **`deploy-to-aws.sh`** - Direct AWS deployment script (pre-Cheetah)
- **`cleanup-aws.sh`** - AWS resource cleanup script

### Legacy Scripts (from root/scripts/)
- **`scripts/setup-secrets.sh`** - Cloud secrets setup (now integrated in Cheetah)
- **`scripts/secure-deploy.sh`** - Secure deployment (now default in Cheetah)

## Migration Status

✅ **REPLACED BY**: `../infrastructure/deploy.sh` using Cheetah platform

**Benefits of new approach:**
- Cloud-agnostic deployment (AWS + Azure)
- Automated security by default
- Cost optimization built-in
- Enterprise CI/CD integration
- Zero-downtime deployments

## Historical Context

These scripts represent the project evolution:
1. **Phase 1**: Direct cloud deployment scripts
2. **Phase 2**: Early Cheetah platform adoption  
3. **Phase 3**: Multi-cloud capability development
4. **Phase 4**: Full Cheetah platform integration

## Current Usage:
Instead of these scripts, use:
```bash
# Multi-cloud deployment via Cheetah
./infrastructure/deploy.sh dev aws
./infrastructure/deploy.sh dev azure
./infrastructure/deploy.sh dev both

# Automated CI/CD pipeline
git push origin main  # Triggers multi-cloud deployment
```

## Status:
🚫 **DEPRECATED** - Replaced by Cheetah platform integration
📁 **ARCHIVED** - Preserved for historical reference and debugging
