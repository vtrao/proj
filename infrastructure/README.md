# Project Infrastructure with Cheetah

This directory contains the infrastructure configuration for the project using the Cheetah platform.

## Structure

```
infrastructure/
├── cheetah/                    # Cheetah infrastructure platform (submodule)
├── environments/              # Environment-specific configurations
│   ├── dev/                   # Development environment
│   ├── staging/              # Staging environment  
│   └── prod/                 # Production environment
├── kubernetes/               # Kubernetes manifests for the application
│   ├── namespace.yaml
│   ├── backend/
│   ├── frontend/
│   └── database/
└── README.md                 # This file
```

## Quick Start

### 1. Deploy Infrastructure

```bash
# Deploy development environment
cd infrastructure/cheetah
./scripts/quickstart.sh

# Or deploy manually
./scripts/deploy.sh aws dev
```

### 2. Deploy Application

```bash
# Get database endpoint from Cheetah
cd cheetah/terraform
DATABASE_ENDPOINT=$(terraform output -raw database_endpoint)

# Update application configuration
cd ../kubernetes
sed -i "s/YOUR_RDS_ENDPOINT/$DATABASE_ENDPOINT/g" database/database-service.yaml

# Deploy application
kubectl apply -f namespace.yaml
kubectl apply -f database/
kubectl apply -f backend/
kubectl apply -f frontend/
```

## Environment Management

### Development
- Single AZ deployment
- Smaller instance types
- Basic monitoring
- Auto-shutdown after hours

### Staging  
- Multi-AZ deployment
- Production-like configuration
- Full monitoring
- Load testing ready

### Production
- High availability
- Auto-scaling
- Comprehensive monitoring
- Backup and disaster recovery

## Integration with Docker Compose

The application can still be run locally with Docker Compose for development:

```bash
# Local development
cd ../
docker-compose up

# Build and test before deploying to cloud
docker-compose build
docker-compose run backend python -m pytest
```

## CI/CD Integration

The project includes GitHub Actions workflows for:
- Building and testing locally
- Deploying to staging on PR merge
- Deploying to production on release tags

## Monitoring

Once deployed, you can access:
- Application metrics via Grafana
- Logs via CloudWatch/Stackdriver
- Cluster status via Kubernetes dashboard

## Cost Management

- Development environment auto-shuts down at night
- Staging uses spot instances where possible
- Production uses reserved instances for cost optimization
- Monthly cost reports are generated automatically

## Security

- All environments use encrypted storage
- Network isolation between environments
- IAM roles follow least privilege principle
- Security scanning in CI/CD pipeline
