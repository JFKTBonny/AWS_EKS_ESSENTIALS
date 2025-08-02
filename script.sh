#Update user context
aws eks update-kubeconfig --name public-endpoint-cluster

#check the oidc provider configuration
aws eks describe-cluster --name $cluster_name --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5
aws eks describe-cluster --name public-endpoint-cluster --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5
#find addon version
kubectl describe daemonset aws-node --namespace kube-system | grep amazon-k8s-cni: | cut -d : -f 3


aws efs describe-mount-targets \
--file-system-id fs-07c1c0cf2209025d2\
--query "MountTargets[*]. {id:MountTargetId,az:AvailabilityZoneName, subnet:SubnetId,EFSIP:IpAddress}" \
--output table


#create the mount target
aws efs create-mount-target \
--file-system-id fs-07c1c0cf2209025d2 \
--security-groups sg-0dd9f218a808428d7 \
--subnet-id subnet-02c5e11b8a3698eb3

aws efs describe-mount-targets \
--file-system-id fs-07c1c0cf2209025d2 \
--query "MountTargets[*]. {id:MountTargetId,az:AvailabilityZoneName, subnet:SubnetId,EFSIP:IpAddress}" \
--output table