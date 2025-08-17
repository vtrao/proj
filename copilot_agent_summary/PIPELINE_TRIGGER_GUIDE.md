# 🚀 CI/CD Pipeline Trigger Guide

## Quick Trigger Commands

### 1. 🔄 **Automatic Triggers** (Recommended)

#### **Full Pipeline (with Deployment)**
```bash
# Trigger full pipeline with deployment
git add .
git commit -m "feat: your feature description"
git push origin main
```
**Result**: Complete CI/CD pipeline runs → deploys to production

#### **Testing Only (No Deployment)**  
```bash
# Create feature branch and PR
git checkout -b feature/your-feature-name
git add .
git commit -m "feat: your feature description"  
git push origin feature/your-feature-name
# Then create Pull Request via GitHub UI
```
**Result**: Tests and validation run, no deployment

---

### 2. 🎛️ **Manual Trigger** (GitHub UI)

**Steps:**
1. Go to: https://github.com/vtrao/proj/actions
2. Click: "🚀 CI/CD Pipeline - Free Tier"
3. Click: "Run workflow" (blue button, top right)
4. Select options:
   - **Branch**: `main` (default)
   - **Environment**: `dev`/`staging`/`prod` 
   - **Force deploy**: `false` (respects quality gates) or `true` (bypasses failures)
5. Click: "Run workflow"

---

### 3. 📋 **Current Pipeline Status**

Check your pipeline status:
- **GitHub Actions**: https://github.com/vtrao/proj/actions
- **Live Application**: http://k8s-projapp-projfree-b22239625a-854912055.us-east-1.elb.amazonaws.com
- **Container Images**: https://github.com/vtrao/proj/pkgs/container/proj

---

### 4. 🔍 **Testing Your Pipeline**

#### **Test with a Simple Change**
```bash
# Make a small change to trigger pipeline
echo "# Pipeline test - $(date)" >> README.md
git add README.md
git commit -m "test: trigger CI/CD pipeline"
git push origin main
```

#### **Monitor the Pipeline**
```bash
# Watch pipeline progress
# Go to: https://github.com/vtrao/proj/actions
# Click on the latest workflow run to see progress
```

---

### 5. 🛠️ **Advanced Triggers**

#### **Security Scan Only**
- **Workflow**: "🔐 Security & Secrets Management"
- **Auto-trigger**: Daily at 2 AM UTC
- **Manual**: Actions → Security workflow → "Run workflow"

#### **Pipeline Validation**
- **Workflow**: "🧪 Pipeline Validation" 
- **Auto-trigger**: When workflow files change
- **Manual**: Actions → Validation workflow → "Run workflow"

#### **Specific Environment Deployment**
```bash
# Manual trigger with specific environment
# Use GitHub UI and select:
# - Environment: "prod" for production
# - Environment: "staging" for staging  
# - Environment: "dev" for development
```

---

### 6. 📊 **Pipeline Monitoring**

#### **Real-time Status**
```bash
# Check current deployment status
kubectl get pods -n proj-app
kubectl get services -n proj-app  
kubectl get ingress -n proj-app
```

#### **Application Health**
```bash
# Test application endpoints
curl http://k8s-projapp-projfree-b22239625a-854912055.us-east-1.elb.amazonaws.com/health
curl http://k8s-projapp-projfree-b22239625a-854912055.us-east-1.elb.amazonaws.com/api/ideas
```

---

### 7. 🚨 **Troubleshooting Failed Pipelines**

#### **View Failure Details**
1. Go to: https://github.com/vtrao/proj/actions
2. Click on failed workflow run (red ❌)
3. Click on failed job to see error logs
4. Expand failed step to see detailed error

#### **Common Issues & Fixes**
```bash
# AWS credentials issue
# → Check GitHub Secrets: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY

# Docker build failure  
# → Test locally: docker build -t proj:test .

# Test failures
# → Run tests locally: cd backend && python -m pytest tests/

# Kubernetes deployment issue
# → Check cluster: aws eks update-kubeconfig --region us-east-1 --name proj-dev-cluster
```

#### **Force Deployment (Bypass Failures)**
```bash
# Use manual trigger with "force_deploy: true"
# This bypasses quality gates - use carefully!
```

---

### 8. 🎯 **Best Practices**

#### **Development Workflow**
```bash
# 1. Create feature branch
git checkout -b feature/new-feature

# 2. Make changes and test locally
docker-compose up  # Test locally first

# 3. Push for PR testing
git push origin feature/new-feature
# Create PR → triggers testing only

# 4. Merge to main for deployment  
# Merge PR → triggers full deployment
```

#### **Production Deployments**
```bash
# Always test in dev first
# Manual trigger → Environment: "dev"
# Verify → Manual trigger → Environment: "prod"
```

#### **Monitoring Free Tier Usage**
```bash
# Check GitHub Actions usage
# Settings → Billing → Plans and usage

# Monitor AWS free tier
# AWS Console → Billing → Free tier
```

---

### 9. 🔄 **Scheduled Triggers**

#### **Automatic Security Scans**
- **When**: Daily at 2:00 AM UTC
- **What**: Full security scan, dependency check, compliance
- **Duration**: ~5-10 minutes
- **Cost**: $0 (uses free GitHub Actions minutes)

#### **Dependabot Updates**
- **When**: Weekly (Monday-Thursday, 5:00 AM)  
- **What**: Creates PRs for dependency updates
- **Triggers**: Automatic testing on dependency PR creation

---

### 10. 📈 **Success Indicators**

#### **Pipeline Success** ✅
- All jobs show green checkmarks
- Application accessible at live URL
- Health endpoint returns "healthy"  
- No security vulnerabilities detected

#### **Pipeline Failure** ❌  
- Red X on failed job
- Deployment rollback triggered automatically
- Previous version remains running
- Error details in workflow logs

---

## 🎉 Quick Start: Trigger Your First Pipeline

**Right now, try this:**

```bash
# Test the pipeline with a simple change
echo "Pipeline test: $(date)" >> PIPELINE_TEST.md
git add PIPELINE_TEST.md
git commit -m "test: verify CI/CD pipeline is working"
git push origin main
```

Then watch it run at: https://github.com/vtrao/proj/actions

**Expected result**: Full pipeline executes in ~8-10 minutes, deploys to your live URL!

---

*Your pipeline is ready and waiting for triggers! 🚀*
