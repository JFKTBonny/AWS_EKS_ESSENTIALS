#Update user context
aws eks update-kubeconfig --name public-endpoint-cluster
# create iam user alice
aws iam create-user --user-name alice
# create iam policy named eks-describe-policy
aws iam create-policy --policy-name <policy-name> --policy-document file://policy.json
# attach eks-describe-policy to alice 
aws iam attach-user-policy --policy-arn arn:aws:iam::ACCOUNTID:policy/eks-describe-policy --user-name alice
# create alice aws access-key
aws iam create-access-key --user-name alice
# update alice user context
aws eks update-kubeconfig --name public-endpoint-cluster --profile alice
# add alice to cluster super admin group
    eksctl create iamidentitymapping \
    --region us-east-1 \
    --cluster public-endpoint-cluster \
    --arn arn:aws:iam::ACCOUNTID:user/alice \
    --group system:masters \
    --no-duplicate-arns
# create a namespace called test-ns
kubectl create ns test-ns
#  add a role to super admin group
eksctl create iamidentitymapping --cluster <cluster-name>
--region=eu-central-1 --arn arn:aws:iam::ACCOUNTID:role/myIAMrole
--group system:masters --username creatorAccount

##user map: add alice to super admin group
  mapUsers: | 
    - userarn: arn:aws:iam::ACCOUNTID:user/alice
      username: alice
      groups:
        - system:masters
