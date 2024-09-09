#!/bin/bash

# Function to delete SageMaker resources
delete_sagemaker_resource() {
  resource_type=$1

  case "$resource_type" in
    "endpoint")
      list_command="aws sagemaker list-endpoints --query 'Endpoints[].EndpointName' --output text"
      delete_command="aws sagemaker delete-endpoint --endpoint-name"
      ;;
    "endpoint-config")
      list_command="aws sagemaker list-endpoint-configs --query 'EndpointConfigs[].EndpointConfigName' --output text"
      delete_command="aws sagemaker delete-endpoint-config --endpoint-config-name"
      ;;
    "model")
      list_command="aws sagemaker list-models --query 'Models[].ModelName' --output text"
      delete_command="aws sagemaker delete-model --model-name"
      ;;
    *)
      echo "Unknown resource type: $resource_type"
      exit 1
      ;;
  esac

  resource_names=$(eval $list_command)
  if [ -n "$resource_names" ]; then
    for name in $resource_names; do
      echo "Attempting to delete SageMaker $resource_type: $name"
      eval "$delete_command $name" && echo "Successfully deleted $resource_type: $name" || echo "Failed to delete $resource_type: $name"
    done
  else
    echo "No $resource_type resources found to delete."
  fi
}

echo "Deleting SageMaker endpoints..."
delete_sagemaker_resource "endpoint"

echo "Deleting SageMaker endpoint configurations..."
delete_sagemaker_resource "endpoint-config"

echo "Deleting SageMaker models..."
delete_sagemaker_resource "model"

echo "Cleanup complete"
