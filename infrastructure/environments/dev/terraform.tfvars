# Development Environment Configuration

# Cloud Provider
cloud_provider = "aws"
environment = "dev"

# AWS Configuration
region = "us-west-2"
availability_zones = ["us-west-2a", "us-west-2b"]

# Kubernetes Cluster
cluster_name = "proj-app-dev"
node_instance_type = "t3.medium"
node_desired_size = 2
node_min_size = 1
node_max_size = 4

# Database
database_instance_class = "db.t3.micro"
database_allocated_storage = 20
database_storage_encrypted = true
database_backup_retention_period = 7
database_backup_window = "03:00-04:00"
database_maintenance_window = "sun:04:00-sun:05:00"

# Networking
vpc_cidr = "10.0.0.0/16"
enable_nat_gateway = true
enable_vpn_gateway = false

# Monitoring
enable_cloudwatch_logs = true
log_retention_days = 7

# Tags
tags = {
  Environment = "development"
  Project     = "proj-app"
  Owner       = "development-team"
  ManagedBy   = "cheetah"
  CostCenter  = "development"
}
