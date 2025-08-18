# IAM and Security Policies

This directory contains AWS IAM policies and security configurations that were used during the AWS-specific deployment phase.

## Policy Files

### AWS IAM Policies
- **`additional_policy.json`** - Additional AWS permissions for EKS operations
- **`additional_ec2_policy.json`** - Extended EC2 permissions for cluster management  
- **`additional-elb-policy.json`** - Elastic Load Balancer permissions
- **`iam_policy.json`** - Main IAM policy for AWS service access

## Current Usage Status

⚠️ **LEGACY**: These policies were used with the deprecated AWS Terraform configurations.

✅ **CURRENT**: The Cheetah platform now handles IAM policies automatically with:
- Least privilege principles
- Automated policy generation  
- Cloud-specific optimizations
- Security best practices built-in

## Policy Evolution

1. **Phase 1**: Manual IAM policy creation (these files)
2. **Phase 2**: Cheetah platform integration with automated IAM
3. **Phase 4**: Enterprise security enhancement with cloud-native secrets

## Security Improvements

The Cheetah platform provides enhanced security:
- **Automated IAM**: Generates minimal required permissions
- **Cloud-Native Secrets**: AWS SSM, Azure Key Vault integration
- **Zero Plaintext**: No hardcoded credentials
- **Audit Trail**: Comprehensive security logging

## Reference Value

These files serve as reference for:
- Understanding historical permission requirements
- Debugging legacy deployments
- Security audit trails
- Migration documentation

For current security configurations, see:
- `../cheetah/terraform/` - Current automated IAM policies
- `../../copilot_agent_summary/SECURITY.md` - Security implementation details
