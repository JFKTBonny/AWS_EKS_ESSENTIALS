# create the assumed role policy for pod identity
data "aws_iam_policy_document" "pod_id_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

# create a role for pod identity
resource "aws_iam_role" "pod_identity_role" {
  name               = "pod-identity-role"
  assume_role_policy = data.aws_iam_policy_document.pod_id_policy.json
}


# Attach the secret manager policy to the role
resource "aws_iam_role_policy_attachment" "secret_manager_policy" {
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  role       = aws_iam_role.pod_identity_role.name
}

# attach the S3 bucket policy to the role
resource "aws_iam_role_policy_attachment" "s3_bucket_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.pod_identity_role.name
}

# Create the client ID or Audience
resource "aws_eks_pod_identity_association" "pod_identity_claim_id" {
  cluster_name    = var.cluster_name
  namespace       = "default"
  service_account = "pod-service-account"
  role_arn        = aws_iam_role.pod_identity_role.arn

  depends_on = [aws_eks_cluster.public_endpoint_cluster]
}

