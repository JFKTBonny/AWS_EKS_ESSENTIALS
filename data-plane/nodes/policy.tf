# Create a policy for the VPC lattice controller
resource "aws_iam_policy" "vpc_lattice" {
 name = "VPCLatticeControllerIAMPolicy"
  path        = "/"
  description = "VPC Lattice Controller IAM Policy "
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "vpc-lattice:*",
                "ec2:DescribeVpcs",
                "ec2:DescribeSubnets",
                "ec2:DescribeTags",
                "ec2:DescribeSecurityGroups",
                "logs:CreateLogDelivery",
                "logs:GetLogDelivery",
                "logs:DescribeLogGroups",
                "logs:PutResourcePolicy",
                "logs:DescribeResourcePolicies",
                "logs:UpdateLogDelivery",
                "logs:DeleteLogDelivery",
                "logs:ListLogDeliveries",
                "tag:GetResources",
                "firehose:TagDeliveryStream",
                "s3:GetBucketPolicy",
                "s3:PutBucketPolicy"
            ],
            "Resource": "*"
        },
        {
            "Effect" : "Allow",
            "Action" : "iam:CreateServiceLinkedRole",
            "Resource" : "arn:aws:iam::*:role/aws-service-role/vpc-lattice.amazonaws.com/AWSServiceRoleForVpcLattice",
            "Condition" : {
                "StringLike" : {
                    "iam:AWSServiceName" : "vpc-lattice.amazonaws.com"
                }
            }
        },
        {
            "Effect" : "Allow",
            "Action" : "iam:CreateServiceLinkedRole",
            "Resource" : "arn:aws:iam::*:role/aws-service-role/delivery.logs.amazonaws.com/AWSServiceRoleForLogDelivery",
            "Condition" : {
                "StringLike" : {
                    "iam:AWSServiceName" : "delivery.logs.amazonaws.com"
                }
            }
        }
    ]
}
 POLICY
}