module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"
  name    = "eks-vpc"
  cidr    = "10.0.0.0/16"

  azs             = ["us-east-2a", "us-east-2b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  tags = {
    Name = "eks-vpc"
  }
}

module "eks" {
    source          = "terraform-aws-modules/eks/aws"
    version         = "19.15.1"

    cluster_name                    = "springboot-eks"
    cluster_version                 = "1.29"
    cluster_endpoint_public_access  = true

    cluster_addons = {
        coredns = {
            most_recent = true
        }
        kube-proxy = {
            most_recent = true
        }
        vpc-cni = {
            most_recent = true
        }
    }

    vpc_id          = module.vpc.vpc_id
    subnet_ids      = module.vpc.private_subnets 

    # Acesso ao endpoint da API EKS

    eks_managed_node_groups = {
        default = {
            desired_capacity = 2
            max_capacity     = 3
            min_capacity     = 1

            instance_types = ["t3.medium"]
        }
    }

    enable_cluster_creator_admin_permissions = true

    # Configuração do aws-auth
    # manage_aws_auth_configmap = true

    # aws_auth_roles = [
    #   {
    #     rolearn  = "arn:aws:iam::881307377501:role/aws-service-role/eks.amazonaws.com/AWSServiceRoleForAmazonEKS"
    #     username = "AWSServiceRoleForAmazonEKS"
    #     groups   = ["system:masters"]
    #   }
    # ]

    # aws_auth_users = [
    #   {
    #     userarn  = "arn:aws:iam::881307377501:user/terraformUser"
    #     username = "terraformUser"
    #     groups   = ["system:masters"]
    #   }
    # ]

    tags = {
      Environment = "production"
      Project     = "example-project"
    }

    # aws_auth_users = [
    #   {
    #     userarn  = "arn:aws:iam::66666666666:user/user1"
    #     username = "user1"
    #     groups   = ["system:masters"]
    #   }
    # ]

    # aws_auth_roles = [
    # {
    #   rolearn  = "arn:aws:iam::123456789012:role/eks-admin-role"
    #   username = "euser1"
    #   groups   = ["system:masters"]
    # }
    #]

}

# module "aws_auth" {
#   source = "terraform-aws-modules/eks/aws//modules/aws-auth"
#   manage_aws_auth_configmap = true

#   depends_on = [module.eks]

#   aws_auth_roles = [
#   {
#     rolearn  = "arn:aws:iam::881307377501:role/github-actions-fiap-pipelike"
#     username = "role1"
#     groups   = ["system:masters"]
#   }
# ]

#   aws_auth_users = [
#     {
#       userarn  = "arn:aws:iam::881307377501:user/terraformUser"
#       username = "user1"
#       groups   = ["system:masters"]
#     }
#   ]
# }
 

resource "aws_ecr_repository" "app_repo" {
  name = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

output "repository_url" {
  value = aws_ecr_repository.app_repo.repository_url
}