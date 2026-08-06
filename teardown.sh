#!/usr/bin/env bash
set -euo pipefail

REGION="us-east-1"
FAILOVER_BUCKET="resilient-failover-leon-2026"

echo "=== Starting Teardown Process in $REGION ==="

# ------------------------------------------------------------------------------
# Function: Delete stack and wait for completion
# ------------------------------------------------------------------------------
delete_stack() {
  local stack_name="$1"

  echo "--> Checking if stack '$stack_name' exists..."
  if aws cloudformation describe-stacks --stack-name "$stack_name" --region "$REGION" >/dev/null 2>&1; then
    echo "    Deleting stack: $stack_name"
    aws cloudformation delete-stack --stack-name "$stack_name" --region "$REGION"
    
    echo "    Waiting for stack '$stack_name' to be completely deleted..."
    aws cloudformation wait stack-delete-complete --stack-name "$stack_name" --region "$REGION"
    echo "    ✓ Stack '$stack_name' deleted successfully."
  else
    echo "    - Stack '$stack_name' does not exist or is already deleted. Skipping."
  fi
}

# ------------------------------------------------------------------------------
# 1. Pre-cleanup: S3 Failover Bucket
# ------------------------------------------------------------------------------
echo "--- Phase 1: Pre-cleanup S3 Resources ---"
if aws s3api head-bucket --bucket "$FAILOVER_BUCKET" --region "$REGION" >/dev/null 2>&1; then
  echo "    Emptying S3 bucket: $FAILOVER_BUCKET"
  aws s3 rm "s3://$FAILOVER_BUCKET" --recursive --region "$REGION" || true
  
  echo "    Deleting S3 bucket: $FAILOVER_BUCKET"
  aws s3 rb "s3://$FAILOVER_BUCKET" --force --region "$REGION" || true
  echo "    ✓ S3 Bucket deleted."
else
  echo "    - Bucket '$FAILOVER_BUCKET' not found. Skipping."
fi

# ------------------------------------------------------------------------------
# 2. Phase 2: Auto-scaling Policies
# ------------------------------------------------------------------------------
echo "--- Phase 2: Deleting Auto-scaling Policies ---"
delete_stack "resilient-worker-autoscaling"
delete_stack "resilient-web-autoscaling"

# ------------------------------------------------------------------------------
# 3. Phase 3: ECS Services & Task Definitions
# ------------------------------------------------------------------------------
echo "--- Phase 3: Deleting ECS Services ---"
delete_stack "resilient-worker-service"
delete_stack "resilient-web-service"

# ------------------------------------------------------------------------------
# 4. Phase 4: Supporting Infrastructure & Backup
# ------------------------------------------------------------------------------
echo "--- Phase 4: Deleting Supporting Infrastructure ---"
delete_stack "resilient-redis"
delete_stack "resilient-backup-service"
delete_stack "resilient-backup" # Handles alternate stack name if used

# ------------------------------------------------------------------------------
# 5. Phase 5: Core Network (VPC, Subnets, Security Groups)
# ------------------------------------------------------------------------------
echo "--- Phase 5: Deleting Base Network Stack ---"
delete_stack "resilient-platform-network"

echo "=== All CloudFormation stacks and temporary resources deleted successfully! ==="
