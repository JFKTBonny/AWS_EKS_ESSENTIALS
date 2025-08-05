#!/bin/bash

set -euo pipefail  # Exit on error, undefined variable, or pipeline failure

# Optional: Apply the GatewayClass manifest for VPC Lattice if needed
# kubectl apply -f https://raw.githubusercontent.com/aws/aws-application-networking-k8s/main/files/controller-installation/gatewayclass.yaml

# Define your EKS cluster name
export CLUSTER_NAME="lattice-cluster"

echo "[INFO] Creating VPC Lattice service network named 'color-app-vpc-lattice-network'..."
aws vpc-lattice create-service-network --name color-app-vpc-lattice-network

# Retrieve the ID of the created service network using its name
echo "[INFO] Fetching Service Network ID..."
SERVICE_NETWORK_ID=$(aws vpc-lattice list-service-networks \
  --query "items[?name=='color-app-vpc-lattice-network'].id" \
  --output text)

# Get the VPC ID where the EKS cluster is deployed
echo "[INFO] Retrieving VPC ID for EKS cluster '$CLUSTER_NAME'..."
CLUSTER_VPC_ID=$(aws eks describe-cluster \
  --name "$CLUSTER_NAME" \
  --query 'cluster.resourcesVpcConfig.vpcId' \
  --output text)

# Associate the VPC with the VPC Lattice service network
echo "[INFO] Creating service network VPC association..."
aws vpc-lattice create-service-network-vpc-association \
  --service-network-identifier "$SERVICE_NETWORK_ID" \
  --vpc-identifier "$CLUSTER_VPC_ID"

# List all current service network–VPC associations for validation
echo "[INFO] Listing service network VPC associations for VPC ID $CLUSTER_VPC_ID..."
aws vpc-lattice list-service-network-vpc-associations \
  --vpc-id "$CLUSTER_VPC_ID"
