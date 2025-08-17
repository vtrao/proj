# Infrastructure Terraform Configuration

This directory contains the Terraform configuration files that should be version-controlled for the proj application.

## File Structure

```
infrastructure/terraform/
├── terraform.tfvars          # Project-specific configuration (COMMIT)
├── .terraform.lock.hcl       # Provider version locks (COMMIT)
├── kubeconfig-aws-dev.yaml   # Generated kubeconfig (IGNORE)
└── README.md                 # This file
```

## File Management

### ✅ **Files to Commit (Team Shared)**
- `terraform.tfvars` - Contains project configuration
- `.terraform.lock.hcl` - Ensures consistent provider versions across team

### ❌ **Files to Ignore (Local/Sensitive)**
- `kubeconfig-aws-dev.yaml` - Contains sensitive cluster access credentials
- Any `*.tfstate` files - Contains sensitive infrastructure state
- `.terraform/` directories - Temporary working directories

## How It Works

1. **Configuration Management**: 
   - Edit `terraform.tfvars` in this directory
   - Deploy script automatically copies it to `cheetah/terraform/` during deployment

2. **State Management**:
   - Terraform state remains in `cheetah/terraform/` (not moved)
   - This preserves the connection to existing AWS infrastructure

3. **Team Collaboration**:
   - Configuration files here are version-controlled
   - State files in cheetah/ are local only
   - Each team member can have their own deployment state

## Usage

```bash
# Edit configuration
vim infrastructure/terraform/terraform.tfvars

# Deploy (automatically uses config from this directory)
cd infrastructure && ./deploy.sh dev aws

# Access cluster (kubeconfig copied here after deployment)
export KUBECONFIG=infrastructure/terraform/kubeconfig-aws-dev.yaml
kubectl get nodes
```

## Security Notes

- Never commit `terraform.tfstate` or `kubeconfig-*` files
- These contain sensitive infrastructure credentials
- Use `.gitignore` to prevent accidental commits
