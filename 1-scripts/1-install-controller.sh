#!/bin/bash

set -euo pipefail  # Exit on error, undefined variable, or pipeline failure

CLUSTER_NAME="lattice-cluster"  # Set your EKS cluster name

###################### Initialization ####################################

# Fetch region, account ID, and VPC ID dynamically
export AWS_REGION=$(aws ec2 describe-availability-zones --output text --query 'AvailabilityZones[0].[RegionName]')
export ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
export VPC_ID=$(aws ec2 describe-vpcs --filter "Name=tag:Name,Values=appmesh-cluster-vpc" --query 'Vpcs[].VpcId' --output text)

echo "[INFO] Updating kubeconfig context for EKS cluster..."
aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$AWS_REGION"

# Cleanup previous deployment if it exists
echo "[INFO] Deleting previous gateway controller namespace (if any)..."
kubectl delete ns aws-application-networking-system --ignore-not-found

# Apply namespace manifest for controller
echo "[INFO] Creating namespace for VPC Lattice controller..."
kubectl apply -f https://raw.githubusercontent.com/aws/aws-application-networking-k8s/main/files/controller-installation/deploy-namesystem.yaml

###################### Networking Permissions ###########################

echo "[INFO] Authorizing VPC Lattice traffic to EKS cluster security group..."
CLUSTER_SG=$(aws eks describe-cluster --name "$CLUSTER_NAME" --region "$AWS_REGION" --output json | jq -r '.cluster.resourcesVpcConfig.clusterSecurityGroupId')

PREFIX_LIST_ID=$(aws ec2 describe-managed-prefix-lists \
  --query "PrefixLists[?PrefixListName=='com.amazonaws.$AWS_REGION.vpc-lattice'].PrefixListId" \
  --output text)

aws ec2 authorize-security-group-ingress \
  --group-id "$CLUSTER_SG" \
  --ip-permissions "PrefixListIds=[{PrefixListId=${PREFIX_LIST_ID}}],IpProtocol=-1"

###################### Service Account ##################################

echo "[INFO] Creating Kubernetes service account for Gateway Controller..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: gateway-api-controller
  namespace: aws-application-networking-system
EOF

###################### Helm Install #####################################

echo "[INFO] Installing VPC Lattice Gateway Controller via Helm..."
aws ecr-public get-login-password --region us-east-1 | helm registry login \
  --username AWS \
  --password-stdin public.ecr.aws

helm install gateway-api-controller \
  oci://public.ecr.aws/aws-application-networking-k8s/aws-gateway-controller-chart \
  --version v1.0.7 \
  --set serviceAccount.create=false \
  --set serviceAccount.name=gateway-api-controller \
  --set role-name=pod-identity-vpc-lattice-role \
  --namespace aws-application-networking-system \
  --set log.level=info

echo "[INFO] Gateway Controller deployment status:"
kubectl get deployment -n aws-application-networking-system
