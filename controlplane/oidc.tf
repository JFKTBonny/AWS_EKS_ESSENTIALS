
# Retrieve the TLS certificate for EKS(IdP)...
# Fetch the TLS certificate used by the EKS cluster's OIDC provider, 
# so you can extract the SHA-1 fingerprint of the certificate.
# This is needed to register the OIDC provider with AWS IAM...
data "tls_certificate" "oidc" {
  url = aws_eks_cluster.public_endpoint_cluster.identity[0].oidc[0].issuer
}

# Register the IdP in the STS...
# This block registers the EKS OIDC identity provider (IdP) with AWS IAM.
# This is required for enabling IAM Roles for Service Accounts (IRSA).
resource "aws_iam_openid_connect_provider" "oidc_openid_connect" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc.certificates[0].sha1_fingerprint]
  url             = data.tls_certificate.oidc.url
}

# Create an assumed role policy and replace the audience(client ID) with a custom audience...
# This builds a trust policy document for an IAM role that allows EKS service accounts to assume it via OIDC...
data "aws_iam_policy_document" "oidc_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc_openid_connect.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:default:irsa-service-account", 
      "system:serviceaccount:ack-system:ack-service-account"]
    }
    principals {
      identifiers = [aws_iam_openid_connect_provider.oidc_openid_connect.arn]
      type        = "Federated"
    }
  }
}

# create a new role IRSA  role
resource "aws_iam_role" "oidc_role" {
  assume_role_policy = data.aws_iam_policy_document.oidc_assume_role_policy.json
  name               = "IRSARole"
}

# attach the s3 policy to the role
resource "aws_iam_role_policy_attachment" "s3_bucket_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       =  aws_iam_role.oidc_role.name
}

# attach the secret manger policy to the role 
resource "aws_iam_role_policy_attachment" "attach_secret_access_policy" {
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  role       =  aws_iam_role.oidc_role.name
}
