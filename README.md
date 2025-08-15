# Proj Application

A full-stack web application with Docker containerization and cloud-native deployment using the Cheetah infrastructure platform.

## 🏗️ Architecture

This project demonstrates a complete journey from local development to cloud production:

- **Local Development**: Docker Compose for rapid development and testing
- **Cloud Infrastructure**: Cheetah platform for cloud-agnostic infrastructure deployment
- **Container Orchestration**: Kubernetes for production-grade container management
- **CI/CD**: GitHub Actions for automated testing and deployment

## 🚀 Quick Start

### Prerequisites

```bash
# Clone the repository with submodules
git clone --recursive git@github.com:vtrao/proj.git

# Or if already cloned, initialize submodules
git submodule update --init --recursive
```

### Local Development

```bash
# Start the application locally
docker-compose up

# Build and test
docker-compose build
docker-compose run backend python -m pytest
```

### Cloud Deployment

```bash
# Deploy to cloud using Cheetah
cd infrastructure
./deploy.sh dev aws

# Test the integration
./test-integration.sh
```

## 📁 Project Structure

```
proj/
├── 📱 frontend/                    # React frontend application
├── 🚀 backend/                     # FastAPI backend application  
├── 🐳 docker-compose.yml           # Local development setup
├── 🏗️ infrastructure/              # Cloud infrastructure configuration
│   ├── 🐆 cheetah/                 # Cheetah infrastructure platform (git submodule)
│   ├── ☸️ kubernetes/              # Kubernetes application manifests
│   ├── 🌍 environments/            # Environment-specific configurations
│   ├── 📋 deploy.sh                # Application deployment script
│   └── 🧪 test-integration.sh     # Integration validation script
├── 🔄 .github/workflows/          # CI/CD pipelines
└── 📖 README.md                   # This file
```

## 🛠️ Technology Stack

### Frontend
- **Framework**: React
- **Container**: Nginx
- **Build**: Multi-stage Docker build

### Backend  
- **Framework**: FastAPI (Python)
- **Database**: PostgreSQL
- **Container**: Python with security hardening

### Infrastructure
- **Platform**: Cheetah (Cloud-agnostic IaC)
- **Orchestration**: Kubernetes (EKS/GKE/AKS)
- **Database**: Managed PostgreSQL (RDS/Cloud SQL/Azure Database)
- **Networking**: VPC with security groups
- **Monitoring**: CloudWatch/Stackdriver integration

## 🔄 Development Workflow

### 0. Working with Submodules

```bash
# Update Cheetah to latest version
cd infrastructure/cheetah
git pull origin main
cd ../..
git add infrastructure/cheetah
git commit -m "update: Cheetah to latest version"

# Check submodule status
git submodule status
```

### 1. Local Development
```bash
# Start services
docker-compose up

# Make changes to code
# Services auto-reload on changes

# Run tests
docker-compose exec backend pytest
```

### 2. Testing & Integration
```bash
# Validate infrastructure setup
cd infrastructure
./test-integration.sh

# Test deployment (dry-run)
./deploy.sh dev aws --dry-run
```

### 3. Deployment
```bash
# Deploy to development
./deploy.sh dev aws

# Deploy to production (via CI/CD)
git push origin main
```

## ☸️ Kubernetes Deployment

The application includes complete Kubernetes manifests:

- **Namespace**: Isolated environment for the application
- **Deployments**: Backend and frontend with health checks
- **Services**: Internal communication and load balancing  
- **Ingress**: External access with path-based routing
- **Secrets**: Database credentials management
- **ConfigMaps**: Application configuration

## 🌩️ Cloud Infrastructure

Powered by the **Cheetah** platform:

### AWS Deployment
- **Compute**: EKS cluster with auto-scaling node groups
- **Database**: RDS PostgreSQL with Multi-AZ
- **Networking**: VPC with public/private subnets
- **Security**: IAM roles, security groups, encryption

### GCP Deployment  
- **Compute**: GKE cluster with node auto-provisioning
- **Database**: Cloud SQL PostgreSQL with high availability
- **Networking**: VPC with firewall rules
- **Security**: IAM bindings, private clusters

## 🔒 Security Features

- **Container Security**: Non-root users, minimal base images
- **Network Security**: Private subnets, security groups
- **Data Security**: Encryption at rest and in transit
- **Access Control**: RBAC, least privilege IAM policies
- **Secrets Management**: Kubernetes secrets, external secret managers

## 📊 Monitoring & Observability

- **Health Checks**: Kubernetes liveness and readiness probes
- **Logging**: Centralized log aggregation
- **Metrics**: Application and infrastructure monitoring
- **Alerting**: Automated incident response

## 💰 Cost Optimization

- **Development**: Auto-shutdown, smaller instances
- **Staging**: Spot instances where possible
- **Production**: Reserved instances, auto-scaling
- **Monitoring**: Cost tracking and optimization recommendations

## 🚀 CI/CD Pipeline

GitHub Actions workflow:
1. **Test**: Run unit tests and integration tests
2. **Build**: Create container images
3. **Deploy**: Automated deployment to environments
4. **Monitor**: Post-deployment validation

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally with Docker Compose
5. Test cloud deployment with Cheetah
6. Submit a pull request

## 📚 Documentation

- [Infrastructure Guide](infrastructure/README.md)
- [Cheetah Documentation](infrastructure/cheetah/README.md)
- [Integration Guide](infrastructure/cheetah/docs/integration-guide.md)

## 📜 License

This project is licensed under the MIT License.

---

**Powered by 🐆 Cheetah - Cloud-agnostic infrastructure at the speed of light!**