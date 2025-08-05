# Define an IAM policy document that allows the EKS Pod Identity service to assume the role.
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    
    # The principal is the EKS Pod Identity service.
    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    # Allow the sts:AssumeRole and sts:TagSession actions, which are required for Pod Identity.
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

# Create an IAM role that can be assumed by pods via Pod Identity.
resource "aws_iam_role" "pod_identity_role" {
  name               = "pod-identity-vpc-lattice-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Attach the required IAM policy (previously defined elsewhere) to the IAM role.
# This policy grants permissions needed by the VPC Lattice Gateway controller.
resource "aws_iam_role_policy_attachment" "vpc_lattice_gateway_controller_policy" {
  policy_arn = aws_iam_policy.vpc_lattice.arn
  role       = aws_iam_role.pod_identity_role.name
}

# Associate the IAM role with a Kubernetes service account using EKS Pod Identity.
# This enables the "gateway-api-controller" in the specified namespace to assume the role.
resource "aws_eks_pod_identity_association" "gateway_controller_sa" {
  cluster_name    = var.cluster_name
  namespace       = "aws-application-networking-system"
  service_account = "gateway-api-controller"
  role_arn        = aws_iam_role.pod_identity_role.arn
}
