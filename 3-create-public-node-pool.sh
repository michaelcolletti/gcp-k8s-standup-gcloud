#!/bin/bash

# ==============================================================================
# 3-create-public-node-pool.sh
# Description: Creates the 'public-nodes' node pool for the GKE cluster.
# Instructions:
#   1. Source the environment script first: `source 0-setup-environment.sh`
#   2. Run this script: `./3-create-public-node-pool.sh`
# ==============================================================================

echo "--- Creating Node Pool: ${GKE_PUBLIC_NODE_POOL_NAME} ---"

# Check if environment variables are set
if [ -z "$GCP_PROJECT_ID" ] || [ -z "$GKE_CLUSTER_NAME" ] || [ -z "$GKE_PUBLIC_NODE_POOL_NAME" ]; then
  echo "Error: Environment variables are not set. Please source 0-setup-environment.sh first."
  exit 1
fi

gcloud container node-pools create ${GKE_PUBLIC_NODE_POOL_NAME} ${GKE_PUBLIC_NODE_POOL_FLAGS}

if [ $? -eq 0 ]; then
  echo "Node pool '${GKE_PUBLIC_NODE_POOL_NAME}' created successfully in cluster '${GKE_CLUSTER_NAME}'."
  echo "Nodes in this pool will have public IP addresses by default."
else
  echo "Error creating node pool '${GKE_PUBLIC_NODE_POOL_NAME}'. Please check the output for details."
  exit 1
fi
