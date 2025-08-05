#!/bin/bash

set -euo pipefail  # Exit on error, undefined variable, or pipeline failure

# Set the name of your EKS cluster
CLUSTER_NAME="istio-cluster"

# Automatically detect and export the AWS region from the first available AZ
export AWS_REGION=$(aws ec2 describe-availability-zones --output text --query 'AvailabilityZones[0].[RegionName]')

# Display update message
echo "[INFO] Updating kubeconfig context for cluster: ${CLUSTER_NAME}"
echo "--------------------------------------------------------"

# Update local kubeconfig to interact with the specified EKS cluster
aws eks update-kubeconfig \
   --name "${CLUSTER_NAME}" \
   --region "${AWS_REGION}"

# Create a namespace for Istio components
kubectl delete namespace istio-system 
kubectl create namespace istio-system 

# Download istioctl if not already installed
if ! command -v istioctl &> /dev/null; then
  echo "Downloading istioctl..."
  curl -L https://istio.io/downloadIstio | sh -
  cd istio-* && export PATH=$PWD/bin:$PATH
fi

# Install Istio with the demo profile (adjust to default or minimal for production use)
echo "Installing Istio with demo profile..."
istioctl install --set profile=demo -y

# Label the default namespace for automatic sidecar injection
echo "Enabling sidecar injection in the default namespace..."
kubectl label namespace default istio-injection=enabled --overwrite

# Confirm installation
echo "Fetching Istio pods in istio-system namespace..."
kubectl get pods -n istio-system
                               