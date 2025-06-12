## GKE Cluster Setup with Declarative gcloud CLI

This guide will walk you through setting up a GKE cluster on GCP using simple, repeatable shell scripts.

1. Environment Setup Script (0-setup-environment.sh)
This script defines all the necessary environment variables for your GKE cluster. Remember to replace your-gcp-project-id with your actual GCP Project ID.

```bash

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
export GCP_PROJECT_ID="your-gcp-project-id"
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
export GKE_MACHINE_TYPE="e2-micro"
# Container-Optimized OS with containerd, recommended for GKE.
export GKE_COS_IMAGE_TYPE="COS_CONTAINERD"
# Number of nodes for the public node pool
export GKE_NUM_NODES_PUBLIC=1

# --- Cluster Creation Flags ---
# We create the cluster without a default node pool (--num-nodes=0)
# This allows us to define custom node pools separately.
# --release-channel=regular: Recommended for production for balanced stability and features.
# --logging=SYSTEM --monitoring=SYSTEM: Enables basic GKE system monitoring and logging.
# --enable-stackdriver-kubernetes: Integrates with Google Cloud operations suite.
# --no-enable-autoupgrade --no-enable-autorepair: Disable auto-upgrades/repairs for instructional
#                                                  purposes to maintain a stable state, but for
#                                                  production, these should typically be enabled.
export GKE_CLUSTER_CREATE_FLAGS="\
  --project=${GCP_PROJECT_ID} \
  --region=${GCP_REGION} \
  --release-channel=regular \
  --machine-type=${GKE_MACHINE_TYPE} \
  --num-nodes=0 \
  --image-type=${GKE_COS_IMAGE_TYPE} \
  --logging=SYSTEM \
  --monitoring=SYSTEM \
  --enable-stackdriver-kubernetes \
  --no-enable-autoupgrade \
  --no-enable-autorepair \
  --node-locations=${GCP_ZONE} \
  --cluster-version=latest" # Use 'latest' for convenience in instructional settings

# --- Node Pool Creation Flags (Public Node Pool) ---
# This node pool will have public IP addresses by default, as it's a standard GKE cluster.
export GKE_PUBLIC_NODE_POOL_FLAGS="\
  --cluster=${GKE_CLUSTER_NAME} \
  --project=${GCP_PROJECT_ID} \
  --region=${GCP_REGION} \
  --machine-type=${GKE_MACHINE_TYPE} \
  --num-nodes=${GKE_NUM_NODES_PUBLIC} \
  --image-type=${GKE_COS_IMAGE_TYPE} \
  --no-enable-autoupgrade \
  --no-enable-autorepair \
  --node-locations=${GCP_ZONE}"

echo "Environment variables set. Please verify GCP_PROJECT_ID: $GCP_PROJECT_ID"
echo "Cluster Name: $GKE_CLUSTER_NAME"
echo "Node Pool Name: $GKE_PUBLIC_NODE_POOL_NAME"
echo "Machine Type: $GKE_MACHINE_TYPE"
echo "Region: $GCP_REGION"
echo "Zone: $GCP_ZONE"


```

2. Enable Necessary APIs (1-enable-apis.sh)
GKE requires several Google Cloud APIs to be enabled in your project. Run this script to ensure they are activated.

```bash

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

```

3. Create the GKE Cluster (2-create-cluster.sh)
This script creates the main GKE cluster. We explicitly set --num-nodes=0 to prevent the creation of a default node pool, allowing us to define our node pools with specific configurations.


```bash

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


4. Create the Public Node Pool (3-create-public-node-pool.sh)
This script creates a dedicated node pool named public-nodes. In a standard GKE cluster, nodes automatically receive public IP addresses, fulfilling the requirement for public access on this node group.

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

```

5. Get Cluster Credentials (4-get-credentials.sh)
After the cluster and node pool are created, you need to configure kubectl to connect to your new cluster.


```bash

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

```

6. Clean Up Resources (5-cleanup-cluster.sh)
Once you are done experimenting, use this script to delete your GKE cluster and associated resources to avoid incurring charges.


```bash

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

```

