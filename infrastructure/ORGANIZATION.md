# Infrastructure Organization

This directory contains organized infrastructure files that were moved from the root directory for better project structure.

## Directory Structure

```
infrastructure/
├── deprecated-aws/          # Legacy AWS Terraform configurations
├── kubernetes-manifests/    # Kubernetes YAML manifests
├── policies/               # IAM and security policies  
├── scripts-archive/        # Test and validation scripts
├── cheetah/               # Cheetah platform submodule
├── kubernetes/            # Current Kubernetes configurations
├── scripts/               # Active deployment scripts
└── terraform/             # Current Terraform configurations
```

## Legacy Files (deprecated-aws/)

Contains old AWS Terraform files that have been replaced by the Cheetah platform:
- `aws-deployment.tf` - Legacy AWS infrastructure definition
- `deploy-aws.tf` - Old AWS deployment configuration  
- `terraform.tfvars` - Legacy Terraform variables
- `multi-stage-Dockerfile` - Old multi-stage Docker build (replaced by service-specific Dockerfiles)

## Kubernetes Manifests

All Kubernetes YAML files organized by:
- `azure/` - Azure-specific Kubernetes manifests
- Root level - General Kubernetes configurations and backups

## Policies

IAM and security policy JSON files:
- AWS IAM policies for EKS and EC2
- Load balancer and additional service policies

## Scripts Archive

Test, validation, and installation scripts:
- Cheetah integration tests
- Platform improvement validations  
- Prerequisites installation scripts
- Legacy script migration tools

## Current Active Infrastructure

For current infrastructure operations, use:
- `./deploy.sh` - Main deployment script using Cheetah platform
- `cheetah/` - Cheetah platform submodule for cloud-agnostic deployments
- `terraform/` - Current Terraform configurations
- `kubernetes/` - Active Kubernetes manifests
