# Files to Clean Up

## Backup Files
- v2_4_7_full.yaml.bak (backup of ALB controller config)

## Redundant/Unused AWS Files  
- aws-deployment.tf (not used, have Cheetah platform)
- deploy-aws.tf (replaced by Cheetah deploy.sh)
- deploy-to-aws.sh (replaced by Cheetah platform)
- deploy-aws-cheetah.sh (old script, superseded)
- kubernetes-aws.yaml (old single-file config)

## Unused Service Files
- backend-loadbalancer-service.yaml (deleted LoadBalancer, using ALB)
- frontend-alb-service.yaml (not used)
- loadbalancer-service.yaml (was deleted from cluster)
- nodeport-services.yaml (not used in final setup)

## Redundant Policy Files
- additional-elb-policy.json (already applied)
- additional_ec2_policy.json (already applied)  
- additional_policy.json (already applied)
- iam_policy.json (already applied)

## Test/Script Files (Keep useful ones)
- test-cheetah-integration.sh (keep)
- test-scripts-move.sh (can remove)
- install-prerequisites.sh (keep for setup)
- cleanup-aws.sh (keep for cleanup)

## Config Files
- aws-load-balancer-sa.yaml (already applied)
- nginx-config.yaml (already applied as configmap)

## Current Active Files (KEEP):
- free-tier-ingress.yaml (active ingress)
- infrastructure/kubernetes/ (active deployments)
- infrastructure/cheetah/ (submodule)
- docker-compose.yml (local dev)
