#!/bin/bash

# ==============================================================================
# 2-create-cluster.sh
# Description: Creates the GKE cluster.
# Instructions:
#   1. Source the environment script first: `source 0-setup-environment.sh`
#   2. Run this script: `./2-create-cluster.sh`
# ==============================================================================

echo "--- Creating GKE Cluster: ${GKE_CLUSTER_NAME} ---"

# Check if environment variables are set
if [ -z "$GCP_PROJECT_ID" ] || [ -z "$GKE_CLUSTER_NAME" ]; then
  echo "Error: Environment variables are not set. Please source 0-setup-environment.sh first."
  exit 1
fi

gcloud container clusters create ${GKE_CLUSTER_NAME} ${GKE_CLUSTER_CREATE_FLAGS}

if [ $? -eq 0 ]; then
  echo "GKE Cluster '${GKE_CLUSTER_NAME}' created successfully."
else
  echo "Error creating GKE Cluster '${GKE_CLUSTER_NAME}'. Please check the output for details."
  exit 1
fi
