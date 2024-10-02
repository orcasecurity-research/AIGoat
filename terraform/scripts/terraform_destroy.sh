#!/bin/bash

# Set variables
STATE_FILE="../terraform.tfstate"
AWS_REGION="us-east-1"  # Replace with your desired AWS region

# Export the AWS region to ensure all AWS CLI commands use this region
export AWS_REGION

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# Destroy all Terraform-managed infrastructure
echo "Destroying all Terraform-managed infrastructure..."
terraform destroy -auto-approve

# Check if the destroy operation was successful
if [ $? -eq 0 ]; then
  echo "Terraform destroy operation was successful."

  # Remove local Terraform state file
  if [ -f "$STATE_FILE" ]; then
    echo "Removing local Terraform state file..."
    rm "$STATE_FILE"
  else
    echo "No local Terraform state file found."
  fi

  # Delete additional AWS resources
  echo "Deleting additional AWS resources..."

  # Delete Lambda functions
  echo "Deleting Lambda functions..."
  LAMBDA_FUNCTIONS=$(aws lambda list-functions --query "Functions[*].FunctionName" --output text)
  for LAMBDA_FUNCTION in $LAMBDA_FUNCTIONS; do
    aws lambda delete-function --function-name $LAMBDA_FUNCTION
  done

  # Delete API Gateway REST APIs
  echo "Deleting API Gateway REST APIs..."
  REST_APIS=$(aws apigateway get-rest-apis --query "items[*].id" --output text)
  for REST_API in $REST_APIS; do
    aws apigateway delete-rest-api --rest-api-id $REST_API
  done

  # Delete EC2 instances
  echo "Deleting EC2 instances..."
  INSTANCE_IDS=$(aws ec2 describe-instances --query "Reservations[*].Instances[*].InstanceId" --output text)
  if [ -n "$INSTANCE_IDS" ]; then
    aws ec2 terminate-instances --instance-ids $INSTANCE_IDS
    aws ec2 wait instance-terminated --instance-ids $INSTANCE_IDS
  fi

  # Delete EC2 security groups (excluding default)
  echo "Deleting EC2 security groups..."
  SECURITY_GROUPS=$(aws ec2 describe-security-groups --query "SecurityGroups[?GroupName!='default'].GroupId" --output text)
  for SECURITY_GROUP in $SECURITY_GROUPS; do
    aws ec2 delete-security-group --group-id $SECURITY_GROUP
  done

  # Delete EC2 network interfaces
  echo "Deleting EC2 network interfaces..."
  NETWORK_INTERFACES=$(aws ec2 describe-network-interfaces --query "NetworkInterfaces[*].NetworkInterfaceId" --output text)
  for NETWORK_INTERFACE in $NETWORK_INTERFACES; do
    aws ec2 delete-network-interface --network-interface-id $NETWORK_INTERFACE
  done

  # Delete EC2 subnets
  echo "Deleting EC2 subnets..."
  SUBNETS=$(aws ec2 describe-subnets --query "Subnets[*].SubnetId" --output text)
  for SUBNET in $SUBNETS; do
    aws ec2 delete-subnet --subnet-id $SUBNET
  done

  # Delete EC2 route tables
  echo "Deleting EC2 route tables..."
  ROUTE_TABLES=$(aws ec2 describe-route-tables --query "RouteTables[*].RouteTableId" --output text)
  for ROUTE_TABLE in $ROUTE_TABLES; do
    aws ec2 delete-route-table --route-table-id $ROUTE_TABLE
  done

  # Delete EC2 DHCP options
  echo "Deleting EC2 DHCP options..."
  DHCP_OPTIONS=$(aws ec2 describe-dhcp-options --query "DhcpOptions[*].DhcpOptionsId" --output text)
  for DHCP_OPTION in $DHCP_OPTIONS; do
    aws ec2 delete-dhcp-options --dhcp-options-id $DHCP_OPTION
  done

  # Delete S3 buckets
  echo "Deleting S3 buckets..."
  BUCKETS=$(aws s3api list-buckets --query "Buckets[*].Name" --output text)
  for BUCKET in $BUCKETS; do
    aws s3 rb s3://$BUCKET --force
  done

  # Delete RDS instances
  echo "Deleting RDS instances..."
  DB_INSTANCE_IDENTIFIERS=$(aws rds describe-db-instances --query "DBInstances[*].DBInstanceIdentifier" --output text)
  for DB_INSTANCE_IDENTIFIER in $DB_INSTANCE_IDENTIFIERS; do
    aws rds delete-db-instance --db-instance-identifier $DB_INSTANCE_IDENTIFIER --skip-final-snapshot
    aws rds wait db-instance-deleted --db-instance-identifier $DB_INSTANCE_IDENTIFIER
  done

  # Delete ElastiCache parameter groups (excluding default)
  echo "Deleting ElastiCache parameter groups..."
  PARAMETER_GROUPS=$(aws elasticache describe-cache-parameter-groups --query "CacheParameterGroups[?CacheParameterGroupName!='default'].CacheParameterGroupName" --output text)
  for PARAMETER_GROUP in $PARAMETER_GROUPS; do
    aws elasticache delete-cache-parameter-group --cache-parameter-group-name $PARAMETER_GROUP
  done

  # Delete MemoryDB parameter groups (excluding default)
  echo "Deleting MemoryDB parameter groups..."
  MEMORYDB_PARAMETER_GROUPS=$(aws memorydb describe-parameter-groups --query "ParameterGroups[?ParameterGroupName!='default'].ParameterGroupName" --output text)
  for MEMORYDB_PARAMETER_GROUP in $MEMORYDB_PARAMETER_GROUPS; do
    aws memorydb delete-parameter-group --parameter-group-name $MEMORYDB_PARAMETER_GROUP
  done

  # Delete KMS keys
  echo "Deleting KMS keys..."
  KMS_KEYS=$(aws kms list-keys --query "Keys[*].KeyId" --output text)
  for KMS_KEY in $KMS_KEYS; do
    aws kms schedule-key-deletion --key-id $KMS_KEY --pending-window-in-days 7
  done

  # Delete Athena workgroups (excluding primary)
  echo "Deleting Athena workgroups..."
  WORKGROUPS=$(aws athena list-work-groups --query "WorkGroups[?Name!='primary'].Name" --output text)
  for WORKGROUP in $WORKGROUPS; do
    aws athena delete-work-group --work-group $WORKGROUP --recursive-delete-option
  done

  # Delete Athena data catalogs (excluding AwsDataCatalog)
  echo "Deleting Athena data catalogs..."
  DATA_CATALOGS=$(aws athena list-data-catalogs --query "DataCatalogsSummary[?CatalogName!='AwsDataCatalog'].CatalogName" --output text)
  for DATA_CATALOG in $DATA_CATALOGS; do
    aws athena delete-data-catalog --name $DATA_CATALOG
  done

  # Delete EventBridge event buses (excluding default)
  echo "Deleting EventBridge event buses..."
  EVENT_BUSES=$(aws events list-event-buses --query "EventBuses[?Name!='default'].Name" --output text)
  for EVENT_BUS in $EVENT_BUSES; do
    aws events delete-event-bus --name $EVENT_BUS
  done

  echo "Cleanup completed successfully."
else
  echo "Terraform destroy operation failed. Cleanup aborted."
fi