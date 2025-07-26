#Update user context
aws eks update-kubeconfig --name public-endpoint-cluster

# create access entry for a principal syntax...
aws eks create-access-entry --cluster-name <CLUSTER_NAME> --principal-arn <IAM_PRINCIPAL_ARN>

# view the available access policies
aws eks list-access-policies --output table

# assign the cluster creator to a principal syntax:
aws eks associate-access-policy \
--cluster-name <CLUSTER_NAME> \
--principal-arn <PRINCIPAL_ARN>\
--policy-arn <POLICY_ARN> \
--access-scope type=<TYPE>

# assign the cluster creator to alice 
aws eks associate-access-policy \
--cluster-name public-endpoint-cluster \
--principal-arn arn:aws:iam::ACCOUNTID:user/alice \
--policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy \
--access-scope type=cluster

# cancel the cluster creator access to alice 
aws eks disassociate-access-policy \
--cluster-name my-cluster \
--principal-arn arn:aws:iam::ACCOUNTID:user/alice \
--policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy

# list all access policies associated to alice
aws eks list-associated-access-policies \
--cluster-name cluster-name \
--principal-arn arn:aws:iam::ACCOUNTID:user/alice

# Create a cluster role binding
kubectl create clusterrolebinding readonly \
--clusterrole=readonly-role \
--group=readonly-group

# delete alice access entry
aws eks delete-access-entry --cluster-name public-endpoint-cluster --principal-arn arn:aws:iam::163447728448:user/alice







