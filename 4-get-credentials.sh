#!/bin/bash

# ==============================================================================
# 4-get-credentials.sh
# Description: Fetches Kubernetes credentials for kubectl.
# Instructions:
#   1. Source the environment script first: `source 0-setup-environment.sh`
#   2. Run this script: `./4-get-credentials.sh`
# ==============================================================================

echo "--- Fetching Kubernetes Credentials ---"

# Check if environment variables are set
if [ -z "$GCP_PROJECT_ID" ] || [ -z "$GKE_CLUSTER_NAME" ] || [ -z "$GCP_REGION" ]; then
  echo "Error: Environment variables are not set. Please source 0-setup-environment.sh first."
  exit 1
fi

gcloud container clusters get-credentials ${GKE_CLUSTER_NAME} \
  --region=${GCP_REGION} \
  --project=${GCP_PROJECT_ID}

if [ $? -eq 0 ]; then
  echo "kubectl is now configured to connect to '${GKE_CLUSTER_NAME}'."
  echo "You can now verify your cluster:"
  echo "  kubectl get nodes"
  echo "  kubectl get pods -A"
else
  echo "Error fetching credentials. Please ensure the cluster is fully created."
  exit 1
fi

