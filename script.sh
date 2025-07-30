
#!/bin/bash

echo "Update context"
echo "-------------------------------"
aws eks update-kubeconfig --name public-endpoint-cluster

# create an AWS S3 Bucket
aws s3api create-bucket \
--bucket <YOUR_BUCKET_NAME> \
--region <AWS_REGION>

# create an AWS ECR
aws ecr create-repository \
    --repository-name docker-images \
    --region <AWS_REGION> \
    --tags '[{"Key":"env","Value":"test"},{"Key":"team","Value":"DevOps"}]'

# create a secret in AWS secret manager    
aws secretsmanager create-secret \
--name app-secret-1 \
--description "test app secret" \
--secret-string '{"SECRET":"SuperSecret"}' \
--region <AWS_REGION>

# awscli installation;
apt update && apt upgrade -y
apt install curl wget unzip -y 
rm -rf aws
curl  "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip  awscliv2.zip  # or unzip -oq awscliv2.zip
./aws/install
aws --version
