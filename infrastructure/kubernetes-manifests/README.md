# Kubernetes Manifests

This directory contains Kubernetes YAML manifests organized by cloud provider and purpose.

## Directory Structure

```
kubernetes-manifests/
├── azure/                  # Azure-specific manifests
│   ├── azure-deployment.yaml
│   └── azure-postgres.yaml
└── v2_4_7_full.yaml.bak   # Backup of complete Kubernetes configuration
```

## Azure Manifests

- **`azure-deployment.yaml`** - Azure AKS deployment configuration
- **`azure-postgres.yaml`** - Azure Database for PostgreSQL configuration

## Backup Files  

- **`v2_4_7_full.yaml.bak`** - Complete Kubernetes deployment backup

## Current Active Manifests

For current deployments, the active Kubernetes configurations are managed by:
- **Cheetah Platform**: `../cheetah/kubernetes/` 
- **Current K8s**: `../kubernetes/`

## Usage

These manifests are primarily for reference and backup purposes. Active deployments use:

```bash
# Deploy via Cheetah platform
./infrastructure/deploy.sh dev azure

# Direct kubectl (if needed)
kubectl apply -f infrastructure/kubernetes/
```

## Migration Notes

These files represent the evolution from manual Kubernetes manifest management to automated deployment via the Cheetah platform integration.
