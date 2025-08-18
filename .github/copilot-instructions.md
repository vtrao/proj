# GitHub Copilot Instructions for Proj

## Architecture Overview

This is a **full-stack web application with cloud-native deployment** using the Cheetah infrastructure platform:

- **Local Development**: Docker Compose with React frontend, FastAPI backend, PostgreSQL database
- **Cloud Infrastructure**: Cheetah platform (git submodule) for cloud-agnostic deployment (AWS/GCP/Azure)
- **Security**: Enterprise-grade secrets management with External Secrets Operator and cloud-native secret stores
- **Deployment**: Two-tier approach - local development + cloud production through Cheetah platform

## Critical Developer Workflows

### Git Submodule Management (Cheetah Platform)
The `infrastructure/cheetah/` directory is a git submodule containing the infrastructure platform:
```bash
# Always clone with submodules
git clone --recursive [repo]
git submodule update --init --recursive

# Update Cheetah platform
cd infrastructure/cheetah && git pull origin main
cd ../.. && git add infrastructure/cheetah && git commit -m "update: Cheetah platform"
```

### Local Development Workflow
```bash
# Start with environment variables (NEVER hardcode secrets)
cp .env.template .env  # Edit with local development values
docker-compose up      # Starts all services with secure defaults

# Database runs on port 5433 (not standard 5432) to avoid conflicts
# Backend API available at http://localhost:8000 (internal network only)
# Frontend available at http://localhost:80
```

### Cloud Deployment Workflow
```bash
# Uses integrated secure deployment from Cheetah platform
./infrastructure/deploy.sh dev aws    # Automatically uses secure-deploy if available
./infrastructure/deploy.sh prod gcp   # Multi-cloud support

# Manual security setup (if needed)
cd infrastructure/cheetah
./scripts/secure-deploy.sh dev aws proj  # PROJECT_NAME must be "proj"
```

## Repository Organization & Directory Structure

### **Root Directory Structure (Post-Cleanup)**
The repository follows enterprise-grade organization with clean separation:
```
proj/
├── backend/                       # Backend application code
├── frontend/                      # Frontend application code
├── infrastructure/                # ALL infrastructure files (organized)
├── copilot_agent_summary/         # Development documentation
├── copilot_agent_rca/            # Root Cause Analysis documents
├── deprecated-scripts/           # Legacy scripts (archived)
├── docker-compose.yml            # Local development
├── PROJECT_DEVELOPMENT_JOURNEY.md # Complete project timeline
└── README.md                     # Main documentation
```

### **Infrastructure Directory Organization**
ALL deployment-related files are in `infrastructure/`:
```
infrastructure/
├── cheetah/                      # Cheetah platform submodule
├── deprecated-aws/               # Legacy AWS Terraform files
├── kubernetes-manifests/         # Kubernetes YAML files
├── policies/                     # IAM and security policies
├── scripts-archive/              # Test/validation scripts
├── deploy.sh                     # Main deployment script
├── kubernetes/                   # Active Kubernetes configs
└── terraform/                    # Current Terraform configs
```

### **CRITICAL: File Location Rules**
- ✅ **Deployment files**: ONLY in `infrastructure/` directory
- ✅ **Legacy files**: Moved to appropriate subdirectories with README
- ✅ **RCA documents**: ONLY in `copilot_agent_rca/` directory
- ✅ **Documentation**: Development docs in `copilot_agent_summary/`
- ❌ **NEVER**: Place deployment files in project root

## Project-Specific Patterns

### Security-First Architecture
- **NO plaintext secrets in code** - Use environment variables with `${VAR:-default}` pattern
- **Environment variable pattern**: `DATABASE_URL: ${DATABASE_URL:-"default_local_value"}`
- **Secrets management**: Cloud-native (AWS SSM, GCP Secret Manager, Azure Key Vault)
- **Docker networks**: Backend on `internal` network (not exposed to host for security)

### Docker Compose Network Architecture
```yaml
networks:
  internal:
    internal: true    # Backend isolated from external access
  public:
    external: false   # Frontend can reach internet
```

### FastAPI Backend Patterns
- **Database connection**: Uses retry logic (5 attempts with 2s delays)
- **Environment config**: `DATABASE_URL` from environment, fallback to local dev values
- **API patterns**: RESTful with `/api/` prefix (e.g., `/api/ideas`)
- **Models**: Pydantic BaseModel with optional `id` and `created_at` fields

### Infrastructure Integration Points
- **Cheetah Platform**: Git submodule at `infrastructure/cheetah/` - contains all cloud deployment logic
- **Deploy Script**: `infrastructure/deploy.sh` wraps Cheetah deployment with project-specific config
- **Security Integration**: Automatically detects and uses `secure-deploy.sh` if available in Cheetah
- **Configuration**: Terraform config in `infrastructure/cheetah/terraform/`, customized via `terraform.tfvars`

### Multi-Cloud Deployment Strategy
The project supports AWS, GCP, and Azure through the Cheetah platform:
- **Cloud Provider Selection**: `./deploy.sh [environment] [aws|gcp|azure]`
- **Secret Stores**: AWS SSM Parameter Store, GCP Secret Manager, Azure Key Vault
- **Kubernetes**: EKS (AWS), GKE (GCP), AKS (Azure)
- **Databases**: RDS (AWS), Cloud SQL (GCP), Azure Database for PostgreSQL

## Key Files and Their Purposes

- `docker-compose.yml`: Local development environment with security patterns
- `infrastructure/deploy.sh`: Project deployment wrapper that leverages Cheetah
- `infrastructure/cheetah/`: Git submodule containing cloud infrastructure platform
- `.env.template`: Template for local development secrets (COPY to `.env`, never commit `.env`)
- `copilot_agent_summary/`: All GitHub Copilot-generated documentation and summary files

## Development Constraints

1. **Never commit secrets**: Use `.env` for local, cloud stores for production
2. **Always use submodule**: Infrastructure changes go through Cheetah platform updates
3. **Project name consistency**: Use "proj" as PROJECT_NAME in deployments
4. **Database port**: Local PostgreSQL on 5433, production uses cloud-managed databases
5. **Network isolation**: Backend not directly accessible in local development (security by design)
6. **Always use free tier resources in cloud deployment on aws or gcp or azure**: Explicitly ask me if you are unsure about the free tier resources available in the cloud provider you are using. And confirm with me before using any paid resources giving the cost implications.
7. **Any update to infrastructure/cheetah/**: Must be committed to the Cheetah submodule, not directly in the project repository
8. **Follow security best practices**: Use cloud-native secret management, no plaintext secrets in code
9. **Agent-generated documentation**: All summary, implementation, and status documentation files generated by GitHub Copilot must be created in the `copilot_agent_summary/` folder to maintain repository organization

## Root Cause Analysis (RCA) Requirements

### **RCA Document Creation**
- **Location**: ALL RCA documents MUST be created in `copilot_agent_rca/` directory
- **Naming Convention**: `RCA_YYYY-MM-DD_HHMM_IncidentDescription.md`
- **Format**: Follow "Working Backwards" 5-Why RCA methodology
- **Required Sections**: Timeline, 5-Why Analysis, Corrective Actions, Prevention Measures

### **RCA Process**
```bash
# Create new RCA document
touch copilot_agent_rca/RCA_2025-08-18_1400_InfrastructureIssue.md

# RCA Structure Requirements:
# 1. Incident Overview (Severity, Duration, Impact)  
# 2. Timeline (Chronological events)
# 3. 5-Why Analysis (Root cause investigation)
# 4. Corrective Action Plan (Immediate + Preventive)
# 5. Implementation Status (Tracking)
# 6. Lessons Learned (Operational improvements)
```

### **Critical Incident Classification**
- **SEV-1 CRITICAL**: System outage, data loss, security breach
- **SEV-2 HIGH**: Performance degradation, partial service impact
- **SEV-3 MEDIUM**: Minor issues, workaround available
- **SEV-4 LOW**: Cosmetic issues, documentation updates

## Directory Management During Operations

### **When Creating New Files**
1. **Infrastructure files** → `infrastructure/[appropriate-subdirectory]/`
2. **RCA documents** → `copilot_agent_rca/`
3. **Development docs** → `copilot_agent_summary/`
4. **Legacy/deprecated** → Move to appropriate archive directory with README

### **When Debugging Issues**
1. Check `infrastructure/deprecated-aws/` for historical AWS configs
2. Review `deprecated-scripts/` for legacy deployment approaches  
3. Reference `copilot_agent_rca/` for previous incident patterns
4. Use `PROJECT_DEVELOPMENT_JOURNEY.md` for project evolution context
