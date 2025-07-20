provider "aws" {
  region = var.aws_region
  profile = "default"
}



# 1. IAM Role that 'joyce' user can assume
resource "aws_iam_role" "eks_cluster_create_role" {
  name = "EKSClusterCreatorRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        AWS = "arn:aws:iam::163447728448:user/joyce"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# 2. Attach AdministratorAccess to the Role
resource "aws_iam_role_policy_attachment" "admin_access" {
  role       = aws_iam_role.eks_cluster_create_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"

  depends_on = [aws_iam_role.eks_cluster_create_role]
}

# 3. Lookup existing AWS IAM user 'joyce'
data "aws_iam_user" "joyce" {
  user_name = "joyce"
}

# 4. Inline policy for 'joyce' allowing to assume the IAM role
resource "aws_iam_user_policy" "assume_role_policy" {
  name = "AllowAssumeEksClusterRole"
  user = data.aws_iam_user.joyce.user_name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = "sts:AssumeRole",
      Resource = aws_iam_role.eks_cluster_create_role.arn
    }]
  })

  depends_on = [aws_iam_role.eks_cluster_create_role]
}
# Create the EKS Describe Cluster Policy
resource "aws_iam_policy" "eks_describe_cluster" {
  name        = "EKSDescribeClusterPolicy"
  description = "Allows describing EKS clusters"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ],
        Resource = "*"
      }
    ]
  })
}
# Attach the Policy to User joyce
resource "aws_iam_user_policy_attachment" "attach_eks_describe_to_joyce" {
  user       = "joyce"
  policy_arn = aws_iam_policy.eks_describe_cluster.arn
}



