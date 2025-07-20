#!/bin/bash
set -e

# Install dependencies
sudo apt update -y
sudo apt install python3-pip -y
pip3 install --upgrade awscli
sudo snap install kubectl --classic

# Configure AWS credentials and profile
mkdir -p /home/ubuntu/.aws

cat <<EOF > /home/ubuntu/.aws/credentials
[joyce-credentials]
aws_access_key_id = <iam user access keyy id>
aws_secret_access_key = <iam user secret access key>
EOF

cat <<EOF > /home/ubuntu/.aws/config
[default]
role_arn = arn:aws:iam::${ACCOUNT ID}:role/EKSClusterCreatorRole
source_profile = joyce-credentials
region = us-east-1
output = json
EOF

# Fix permissions
chown -R ubuntu:ubuntu /home/ubuntu/.aws

# Update kubeconfig
su - ubuntu -c "aws eks update-kubeconfig --name private-endpoint-cluster"
