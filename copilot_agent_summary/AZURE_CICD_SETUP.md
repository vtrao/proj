# 🔷 Azure CI/CD Setup Guide

## Quick Setup for Azure Integration

To enable Azure deployments in the CI/CD pipeline, you need to configure Azure service principal credentials.

### 1. Create Azure Service Principal

```bash
# Login to Azure
az login

# Create service principal for GitHub Actions
az ad sp create-for-rbac \
  --name "proj-cicd-sp" \
  --role contributor \
  --scopes /subscriptions/{subscription-id} \
  --sdk-auth

# Output will be JSON like this:
{
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientSecret": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

### 2. Add GitHub Secret

1. Go to your GitHub repository
2. Navigate to Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Name: `AZURE_CREDENTIALS`
5. Value: Paste the entire JSON output from step 1

### 3. Grant Additional Permissions

The service principal needs additional permissions for AKS:

```bash
# Get your subscription ID
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# Get the service principal object ID
SP_OBJECT_ID=$(az ad sp list --display-name "proj-cicd-sp" --query [0].id -o tsv)

# Grant Azure Kubernetes Service Cluster Admin Role
az role assignment create \
  --assignee $SP_OBJECT_ID \
  --role "Azure Kubernetes Service Cluster Admin Role" \
  --scope "/subscriptions/$SUBSCRIPTION_ID"

# Grant Azure Container Registry Admin (if using ACR)
az role assignment create \
  --assignee $SP_OBJECT_ID \
  --role "AcrPush" \
  --scope "/subscriptions/$SUBSCRIPTION_ID"
```

### 4. Verify Azure Infrastructure

Ensure your Azure infrastructure is deployed:

```bash
# Check if resource group exists
az group show --name proj-dev-rg

# Check if AKS cluster exists
az aks show --resource-group proj-dev-rg --name proj-dev-aks

# Get AKS credentials locally (for testing)
az aks get-credentials --resource-group proj-dev-rg --name proj-dev-aks
kubectl get nodes
```

### 5. Test Deployment

You can now test the Azure deployment:

1. Go to GitHub Actions in your repository
2. Click "Run workflow" on the CI/CD Pipeline
3. Select:
   - Environment: `dev`
   - Deployment Strategy: `azure-only`
   - Force Deploy: `false`
4. Click "Run workflow"

### 6. Verify Deployment

After deployment, check:

1. **GitHub Actions Logs**: Review the deployment steps
2. **Azure Portal**: Check AKS cluster and pod status
3. **Application URL**: Test http://4.156.246.77
4. **Kubernetes**: Use `kubectl get pods -n proj-app`

## Troubleshooting

### Common Issues

#### Service Principal Permission Issues
```bash
# If you get permission errors, ensure the service principal has:
# 1. Contributor role on subscription
# 2. AKS Cluster Admin role
# 3. ACR Push role (if using Azure Container Registry)
```

#### AKS Access Issues
```bash
# Verify cluster exists and is accessible
az aks get-credentials --resource-group proj-dev-rg --name proj-dev-aks --admin
kubectl cluster-info
```

#### Network Connectivity Issues
```bash
# Check if public IP is accessible
curl -v http://4.156.246.77
```

### Debug Commands

```bash
# Check Azure login status
az account show

# List available AKS clusters
az aks list --output table

# Check pod status in AKS
kubectl get pods -n proj-app -o wide

# View pod logs
kubectl logs -l app=proj-frontend -n proj-app
kubectl logs -l app=proj-backend -n proj-app
```

## Security Best Practices

1. **Rotate Service Principal Secret**: Regularly rotate the client secret
2. **Principle of Least Privilege**: Only grant minimum required permissions
3. **Monitor Access**: Review Azure AD sign-in logs for the service principal
4. **Separate Environments**: Use different service principals for dev/staging/prod

## Next Steps

Once Azure CI/CD is working:

1. **Monitor Costs**: Use Azure Cost Management to track expenses
2. **Set Up Alerts**: Configure Azure Monitor alerts for applications
3. **Optimize Resources**: Review and optimize VM sizes and storage
4. **Security Scanning**: Enable Azure Security Center recommendations
5. **Backup Strategy**: Implement backup for persistent data

---

**Your multi-cloud CI/CD pipeline is now ready to deploy to both AWS and Azure! 🚀**
