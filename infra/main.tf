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
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = "springboot-eks"
  cluster_version = "1.31"

  cluster_endpoint_public_access = true

  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
      default = {
          desired_capacity = 2
          max_capacity     = 3
          min_capacity     = 1

          instance_types = ["t3.medium"]
      }
  }

  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets 

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}


resource "aws_ecr_repository" "app_repo" {
  name = var.ecr_repository_name
  image_tag_mutability = "IMMUTABLE" # não permite que as tags das imagens sejam alteradas
  force_delete         = true # permite destruir o repositório mesmo que existam imagens dentro dele
}

output "repository_url" {
  value = aws_ecr_repository.app_repo.repository_url
}