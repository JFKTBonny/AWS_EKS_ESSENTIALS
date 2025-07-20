provider "aws" {
  region  = "us-east-1"
  profile = "joyce-role"
}

module "iam_role" {
  source = "./iam-role"

  
}

module "vpc" {
  source = "./data-plane/network"
  depends_on = [module.iam_role]  # VPC destroyed before IAM role
}

module "cluster" {
  source         = "./control-plane"
  eni_subnet_ids = module.vpc.eni_subnet_ids
  vpc_id         = module.vpc.vpc_id
  depends_on = [module.iam_role]  # Cluster destroyed before IAM role
}

module "nodes" {
  source                    = "./data-plane/nodes"
  cluster_name              = module.cluster.cluster_name
  subnet_ids                = module.vpc.private_subnet_ids
  cluster_security_group_id = module.cluster.cluster_security_group_id
  depends_on = [module.iam_role]  # Nodes destroyed before IAM role
}

module "instance" {
  source    = "./bastion"
  subnet_id = module.vpc.public_subnet_ids[0]
  vpc_id    = module.vpc.vpc_id
  depends_on = [module.iam_role]  # Instance destroyed before IAM role
}
