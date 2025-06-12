#!/bin/bash

# ==============================================================================
# 5-cleanup-cluster.sh
# Description: Deletes the GKE node pool and cluster.
# Instructions:
#   1. Source the environment script first: `source 0-setup-environment.sh`
#   2. Run this script: `./5-cleanup-cluster.sh`
# ==============================================================================

echo "--- Cleaning up GKE Cluster Resources ---"

# Check if environment variables are set
if [ -z "$GCP_PROJECT_ID" ] || [ -z "$GKE_CLUSTER_NAME" ] || [ -z "$GKE_PUBLIC_NODE_POOL_NAME" ] || [ -z "$GCP_REGION" ]; then
  echo "Error: Environment variables are not set. Please source 0-setup-environment.sh first."
  exit 1
fi

# Delete the node pool first
echo "Deleting node pool: ${GKE_PUBLIC_NODE_POOL_NAME}..."
gcloud container node-pools delete ${GKE_PUBLIC_NODE_POOL_NAME} \
  --cluster=${GKE_CLUSTER_NAME} \
  --region=${GCP_REGION} \
  --project=${GCP_PROJECT_ID} \
  --quiet # --quiet flag for non-interactive deletion

if [ $? -ne 0 ]; then
  echo "Warning: Error deleting node pool. Attempting to delete cluster anyway."
fi

# Delete the cluster
echo "Deleting cluster: ${GKE_CLUSTER_NAME}..."
gcloud container clusters delete ${GKE_CLUSTER_NAME} \
  --region=${GCP_REGION} \
  --project=${GCP_PROJECT_ID} \
  --quiet # --quiet flag for non-interactive deletion

if [ $? -eq 0 ]; then
  echo "GKE Cluster '${GKE_CLUSTER_NAME}' and its node pool have been successfully deleted."
else
  echo "Error deleting GKE Cluster '${GKE_CLUSTER_NAME}'. Please check the output for details."
  echo "You may need to manually delete it via the GCP Console or resolve any lingering issues."
  exit 1
fi