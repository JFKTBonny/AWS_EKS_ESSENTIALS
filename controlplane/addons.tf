# ✅ Creates the VPC CNI addon for EKS (enables advanced networking features)
resource "aws_eks_addon" "vpc_cni_addon" {
  cluster_name = aws_eks_cluster.public_endpoint_cluster.name
  addon_name   = "vpc-cni"
  configuration_values = jsonencode({
    env = {
      ENABLE_PREFIX_DELEGATION = "true" # Enables prefix delegation mode for higher pod density
      WARM_PREFIX_TARGET       = "1"    # Keeps 1 unused prefix ready for new pods
    }
  })
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}

# ✅ IAM role used by addons via OIDC (shared by vpc-cni, EBS, and EFS CSI drivers)
resource "aws_iam_role" "oidc_roles" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  name               = "vpc-cni-roles"
}

# ✅ Attach AmazonEKS_CNI_Policy to allow VPC CNI to manage network interfaces
resource "aws_iam_role_policy_attachment" "cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.oidc_roles.name
}

# ✅ IAM role definition for EBS CSI driver (still uses shared OIDC policy)
resource "aws_iam_role" "ebs" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  name               = "ebs-role"
}

# ✅ Attach AmazonEBSCSIDriverPolicy to allow EBS volumes to be provisioned and managed
resource "aws_iam_role_policy_attachment" "ebs" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.oidc_roles.name
}

# ✅ IAM role definition for EFS CSI driver (same shared role again)
resource "aws_iam_role" "efs" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  name               = "efs-role"
}

# ✅ Attach AmazonEFSCSIDriverPolicy to allow mounting and managing EFS volumes
resource "aws_iam_role_policy_attachment" "efs" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
  role       = aws_iam_role.oidc_roles.name
}

# ✅ Deploys the EBS CSI addon to the EKS cluster
resource "aws_eks_addon" "ebs-csi" {
  cluster_name             = aws_eks_cluster.public_endpoint_cluster.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.31.0-eksbuild.1"
  service_account_role_arn = aws_iam_role.oidc_roles.arn
  tags = {
    "eks_addon" = "ebs-csi"
    "terraform" = "true"
  }
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on = [aws_iam_openid_connect_provider.oidc_openid_connect]
}

# ✅ Deploys the EFS CSI addon to the EKS cluster
resource "aws_eks_addon" "efs-csi" {
  cluster_name             = aws_eks_cluster.public_endpoint_cluster.name
  addon_name               = "aws-efs-csi-driver"
  addon_version            = "v2.0.2-eksbuild.1"
  service_account_role_arn = aws_iam_role.oidc_roles.arn
  tags = {
    "eks_addon" = "efs-csi"
    "terraform" = "true"
  }
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on = [aws_iam_openid_connect_provider.oidc_openid_connect]
}





# https://aws.amazon.com/blogs/containers/amazon-ebs-csi-driver-is-now-generally-available-in-amazon-eks-add-ons/ 

