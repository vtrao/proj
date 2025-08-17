# 🌐 Multi-Cloud CI/CD Pipeline Documentation

## Overview

The enhanced CI/CD pipeline now supports deployment to both AWS and Azure cloud platforms with flexible deployment strategies. This pipeline leverages the Cheetah framework for consistent infrastructure management across cloud providers.

## 🚀 Pipeline Features

### Deployment Strategies
- **`both`** (default): Deploy to both AWS and Azure simultaneously
- **`aws-only`**: Deploy only to AWS EKS cluster
- **`azure-only`**: Deploy only to Azure AKS cluster

### Multi-Cloud Architecture
```
GitHub Repository
├── 🔍 Code Analysis & Testing (Shared)
├── 🏗️  Container Building (Shared)
├── 🎯 Deployment Orchestrator
├── ☁️  AWS Deployment (Conditional)
├── 🔷 Azure Deployment (Conditional)
├── 📊 Multi-Cloud Monitoring
└── 🚨 Multi-Cloud Rollback (On Failure)
```

## 📋 Deployment Configuration

### Manual Deployment Triggers
Use GitHub Actions workflow dispatch to trigger deployments with custom settings:

```yaml
Environment Options:
  - dev
  - staging 
  - prod

Deployment Strategy Options:
  - both (default)
  - aws-only
  - azure-only

Force Deploy:
  - false (default)
  - true (override test failures)
```

### Automatic Deployment Triggers
- **Push to main**: Deploys to both clouds by default
- **Push to develop**: Deploys to both clouds by default
- **Pull Request**: Code analysis and testing only (no deployment)

## 🌐 Cloud Provider Configuration

### AWS Configuration
- **Cluster**: EKS proj-dev-cluster (us-east-1)
- **URL**: http://k8s-projapp-projenha-1c91b63e01-1661544353.us-east-1.elb.amazonaws.com
- **Environment**: aws-{environment}
- **Secrets Required**: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY

### Azure Configuration  
- **Cluster**: AKS proj-dev-aks (East US)
- **Resource Group**: proj-dev-rg
- **URL**: http://4.156.246.77
- **Environment**: azure-{environment}
- **Secrets Required**: AZURE_CREDENTIALS

## 🔧 Required Secrets

### AWS Secrets
```bash
AWS_ACCESS_KEY_ID=AKIAXXXXXXXXXXXXX
AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### Azure Secrets
```json
AZURE_CREDENTIALS={
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientSecret": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", 
  "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

### GitHub Container Registry
- Automatically uses GITHUB_TOKEN for GHCR access
- No additional configuration required

## 🏗️ Pipeline Jobs Breakdown

### 1. Code Analysis (Shared)
- Python code analysis (flake8, bandit, safety)
- JavaScript code analysis (ESLint, npm audit)
- Quality gate evaluation
- Security scanning

### 2. Testing (Shared)
- Backend tests (pytest with coverage)
- Frontend tests (Jest with coverage)
- Integration tests (structure validation)

### 3. Build & Containerization (Shared)
- Multi-architecture Docker builds (linux/amd64)
- GitHub Container Registry push
- Container security scanning
- Build caching optimization

### 4. Deployment Orchestrator
- Analyzes deployment strategy
- Sets cloud deployment flags
- Configures environment URLs
- Generates deployment preview

### 5. AWS Deployment (Conditional)
```yaml
Triggers:
  - deployment_strategy: 'both' OR 'aws-only'
  - Manual workflow dispatch
  - Push to main/develop

Steps:
  - Configure AWS credentials
  - Setup kubectl for EKS
  - Create/update GHCR pull secrets
  - Deploy to EKS cluster
  - Health checks and verification
```

### 6. Azure Deployment (Conditional)
```yaml
Triggers:
  - deployment_strategy: 'both' OR 'azure-only'
  - Manual workflow dispatch
  - Push to main/develop

Steps:
  - Azure login with service principal
  - Setup kubectl for AKS
  - Create/update GHCR pull secrets
  - Deploy to AKS cluster
  - Health checks and verification
```

### 7. Multi-Cloud Monitoring
- Collects deployment status from all clouds
- Generates comprehensive deployment report
- Cost analysis and optimization recommendations
- Links to deployed applications

### 8. Multi-Cloud Rollback (On Failure)
- Automatic rollback on deployment failures
- Cloud-specific rollback procedures
- Recovery instructions and next steps

## 📊 Deployment Reports

The pipeline generates comprehensive deployment reports in GitHub Actions summary:

### Report Sections
1. **Deployment Configuration**: Strategy, environment, container images
2. **Cloud Provider Status**: Success/failure status with links
3. **Cost Analysis**: Monthly cost estimates for each cloud
4. **Next Steps**: Testing, monitoring, and maintenance instructions

### Example Report
```markdown
## 🌐 Multi-Cloud Deployment Report

### Deployment Configuration
- Environment: dev
- Strategy: both
- Container Image: ghcr.io/vtrao/proj:abc1234

### Cloud Provider Status
| Provider | Status | URL |
|----------|--------|-----|
| 🟢 AWS | ✅ Success | [AWS App](http://k8s-projapp-projenha-1c91b63e01-1661544353.us-east-1.elb.amazonaws.com) |
| 🔵 Azure | ✅ Success | [Azure App](http://4.156.246.77) |

### Cost Analysis
- AWS Monthly Cost: ~$203-270 (Production ready)
- Azure Monthly Cost: ~$11-42 (Free tier optimized)
- Total Monthly Cost: ~$214-312
```

## 💰 Cost Optimization

### AWS Deployment Costs
- **EKS Cluster**: $72/month (control plane)
- **EC2 Instances**: $60-180/month (t3.medium nodes)
- **RDS Database**: $13-15/month (db.t3.micro)
- **Load Balancer**: $16-25/month
- **Total**: ~$203-270/month

### Azure Deployment Costs
- **AKS Cluster**: $0/month (Free tier)
- **VM Instances**: $0-29/month (Standard_B2s with free tier)
- **Container Registry**: $5/month (Basic SKU)
- **Storage**: $2-3/month
- **Total**: ~$11-42/month

### Cost Optimization Features
- Free tier maximization on Azure
- Resource tagging for cost tracking
- Automatic cost monitoring and reporting
- Recommendations for cost reduction

## 🔄 Usage Examples

### Deploy to Both Clouds (Default)
```bash
# Triggered automatically on push to main
git push origin main

# Or manually via GitHub Actions UI:
# Environment: dev
# Deployment Strategy: both
```

### Deploy to AWS Only
```bash
# Via GitHub Actions workflow dispatch:
# Environment: dev
# Deployment Strategy: aws-only
```

### Deploy to Azure Only
```bash
# Via GitHub Actions workflow dispatch:
# Environment: dev
# Deployment Strategy: azure-only
```

### Emergency Rollback
Rollbacks happen automatically on deployment failures, but can also be triggered manually by rerunning the rollback job.

## 🚨 Troubleshooting

### Common Issues

#### AWS Authentication Failures
```bash
# Check AWS credentials in GitHub secrets
# Ensure IAM user has EKS and ECR permissions
# Verify region configuration (us-east-1)
```

#### Azure Authentication Failures
```bash
# Verify AZURE_CREDENTIALS service principal
# Check subscription and tenant IDs
# Ensure service principal has AKS permissions
```

#### Container Registry Issues
```bash
# GHCR uses GITHUB_TOKEN automatically
# Check if repository is public or token has packages:write scope
# Verify image names and tags
```

#### Kubernetes Deployment Failures
```bash
# Check pod status: kubectl get pods -n proj-app
# Review pod logs: kubectl logs <pod-name> -n proj-app
# Verify image pull secrets exist
```

### Debug Steps
1. **Check Pipeline Logs**: Review detailed logs in GitHub Actions
2. **Verify Secrets**: Ensure all required secrets are configured
3. **Test Connectivity**: Verify cloud provider access
4. **Check Resources**: Confirm clusters and infrastructure exist
5. **Manual Deployment**: Try deploying via Cheetah CLI locally

## 🔮 Future Enhancements

### Planned Features
1. **Blue-Green Deployments**: Zero-downtime deployments
2. **Canary Releases**: Gradual rollout strategies
3. **Multi-Environment Support**: Dev, staging, prod pipelines
4. **Advanced Monitoring**: Metrics, logging, and alerting integration
5. **Cost Optimization Automation**: Automatic scaling and resource optimization

### Integration Opportunities
1. **Slack Notifications**: Deployment status alerts
2. **Jira Integration**: Automated ticket updates
3. **Security Scanning**: Enhanced vulnerability detection
4. **Performance Testing**: Automated load testing
5. **Compliance Checking**: Automated security and compliance validation

## 📚 Additional Resources

- [Cheetah Framework Documentation](../infrastructure/cheetah/README.md)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Azure AKS Documentation](https://docs.microsoft.com/en-us/azure/aks/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

---

**The multi-cloud CI/CD pipeline provides enterprise-grade deployment automation with cost optimization, security best practices, and reliable rollback mechanisms across AWS and Azure platforms.**
