# This resource installs or updates the Amazon VPC CNI (Container Network Interface) add-on for the EKS cluster.
resource "aws_eks_addon" "vpc_cni_addon" {
  cluster_name = var.cluster_name                     # The name of the EKS cluster
  addon_name   = "vpc-cni"                            # The name of the add-on to install
  addon_version = "v1.18.5-eksbuild.1"                # Specific version of the VPC CNI add-on

  # Configuration overrides for the add-on
  configuration_values = jsonencode({
    env = {
      ENABLE_PREFIX_DELEGATION = "true"               # Enables prefix delegation mode to optimize IP allocation
      WARM_PREFIX_TARGET       = "1"                  # Keeps 1 prefix ready for faster pod launches
    }
  })

  # Resolve conflicts during creation or update by overwriting existing add-on settings
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  # Ensure the cluster is created before applying this add-on
  depends_on = [aws_eks_cluster.lattice-cluster]
}

# This resource installs the EKS Pod Identity Agent add-on, which enables IAM roles for service accounts (IRSA)
# via the newer Pod Identity mechanism.
resource "aws_eks_addon" "pod_idenity_addon" {
  cluster_name = var.cluster_name                     # The name of the EKS cluster
  addon_name   = "eks-pod-identity-agent"             # The name of the Pod Identity add-on

  # Depends on the EKS cluster being created first
  depends_on = [aws_eks_cluster.lattice-cluster]
}
