resource "aws_eks_cluster" "lattice-cluster" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.cluster_role.arn
  #configure data plane subnets and eni
  vpc_config {
    subnet_ids = concat(
      var.private_subnet_ids
    )
    endpoint_public_access  = "true"
  }
  depends_on = [ aws_iam_role.cluster_role ]
}

resource "null_resource" "update_kubeconfig" {
  provisioner "local-exec" {
    command = <<EOT
      aws eks update-kubeconfig \
        --region ${var.region} \
        --name ${var.cluster_name}
    EOT
  }

  triggers = {
    cluster_name = aws_eks_cluster.lattice-cluster.name
  }

  depends_on = [aws_eks_cluster.lattice-cluster]
}
