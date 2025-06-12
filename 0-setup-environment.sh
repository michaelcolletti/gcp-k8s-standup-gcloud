#!/bin/bash

# ==============================================================================
# 0-setup-environment.sh
# Description: Sets up environment variables for GKE cluster creation.
# Instructions:
#   1. Replace "your-gcp-project-id" with your actual GCP Project ID.
#   2. Source this script: `source 0-setup-environment.sh`
# ==============================================================================

echo "--- Setting up Environment Variables ---"

# --- GCP Project and Location Settings ---
# Replace with your GCP Project ID
export GCP_PROJECT_ID=`gcloud config get-value project`
# Recommended region for your cluster (e.g., us-central1, europe-west1)
export GCP_REGION="us-central1"
# Specific zone within the region for node placement
export GCP_ZONE="us-central1-a"

# --- GKE Cluster and Node Pool Names ---
export GKE_CLUSTER_NAME="my-declarative-gke-cluster"
export GKE_PUBLIC_NODE_POOL_NAME="public-nodes"

# --- VM Configuration (Cheapest Available) ---
# e2-micro is typically the cheapest machine type available on GKE.
# It provides 2 vCPUs and 1 GB memory.
export GKE_MACHINE_TYPE="e2-small"
# Container-Optimized OS with containerd, recommended for GKE.
export GKE_COS_IMAGE_TYPE="COS_CONTAINERD"
# Number of nodes for the public node pool
export GKE_NUM_NODES_PUBLIC=1

# --- Cluster Creation Flags ---
# We create the cluster without a default node pool (--num-nodes=0)
# This allows us to define custom node pools separately.
# --release-channel=regular: Recommended for production for balanced stability and features.
# --logging=SYSTEM --monitoring=SYSTEM: Enables basic GKE system monitoring and logging.
# Removed --enable-stackdriver-kubernetes as it conflicts with --logging and --monitoring.
# --enable-autoupgrade --enable-autorepair: Enabled for regular release channel as required by GKE.
export GKE_CLUSTER_CREATE_FLAGS="\
  --project=${GCP_PROJECT_ID} \
  --region=${GCP_REGION} \
  --release-channel=regular \
  --machine-type=${GKE_MACHINE_TYPE} \
  --num-nodes=0 \
  --image-type=${GKE_COS_IMAGE_TYPE} \
  --logging=SYSTEM \
  --monitoring=SYSTEM \
  --enable-autoupgrade \
  --enable-autorepair \
  --node-locations=${GCP_ZONE} \
  --cluster-version=latest" # Use 'latest' for convenience in instructional settings

# --- Node Pool Creation Flags (Public Node Pool) ---
# This node pool will have public IP addresses by default, as it's a standard GKE cluster.
# --enable-autoupgrade --enable-autorepair: Enabled for regular release channel as required by GKE.
export GKE_PUBLIC_NODE_POOL_FLAGS="\
  --cluster=${GKE_CLUSTER_NAME} \
  --project=${GCP_PROJECT_ID} \
  --region=${GCP_REGION} \
  --machine-type=${GKE_MACHINE_TYPE} \
  --num-nodes=${GKE_NUM_NODES_PUBLIC} \
  --image-type=${GKE_COS_IMAGE_TYPE} \
  --enable-autoupgrade \
  --enable-autorepair \
  --node-locations=${GCP_ZONE}"

echo "Environment variables set. Please verify GCP_PROJECT_ID: $GCP_PROJECT_ID"
echo "Cluster Name: $GKE_CLUSTER_NAME"
echo "Node Pool Name: $GKE_PUBLIC_NODE_POOL_NAME"
echo "Machine Type: $GKE_MACHINE_TYPE"
echo "Region: $GCP_REGION"
echo "Zone: $GCP_ZONE"