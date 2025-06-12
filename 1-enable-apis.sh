#!/bin/bash

# ==============================================================================
# 1-enable-apis.sh
# Description: Enables required Google Cloud APIs for GKE.
# Instructions:
#   1. Source the environment script first: `source 0-setup-environment.sh`
#   2. Run this script: `./1-enable-apis.sh`
# ==============================================================================

echo "--- Enabling Required Google Cloud APIs ---"

# If GCP_PROJECT_ID is not set from environment script, try to get it from gcloud config
if [ -z "$GCP_PROJECT_ID" ]; then
  echo "GCP_PROJECT_ID not set. Attempting to retrieve from gcloud config..."
  export GCP_PROJECT_ID=$(gcloud config get-value project)
  if [ -z "$GCP_PROJECT_ID" ]; then
    echo "Error: GCP_PROJECT_ID could not be determined. Please set it in 0-setup-environment.sh or configure gcloud CLI."
    exit 1
  else
    echo "Using GCP_PROJECT_ID from gcloud config: ${GCP_PROJECT_ID}"
  fi
fi

gcloud config set project ${GCP_PROJECT_ID}

# List of APIs to enable
APIS=(
  "container.googleapis.com"
  "compute.googleapis.com"
  "monitoring.googleapis.com"
  "logging.googleapis.com"
)

for api in "${APIS[@]}"; do
  echo "Enabling API: ${api}..."
  gcloud services enable ${api} --project=${GCP_PROJECT_ID}
  if [ $? -ne 0 ]; then
    echo "Error enabling ${api}. Please check your permissions or project ID."
    exit 1
  fi
done

echo "All required APIs are enabled."
