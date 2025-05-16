
module "aws_auth" {
  source = "terraform-aws-modules/eks/aws//modules/aws-auth"
  manage_aws_auth_configmap = true

  depends_on = [module.eks]

  aws_auth_roles = [
  {
    rolearn  = "arn:aws:iam::881307377501:role/github-actions-fiap-pipelike"
    username = "role1"
    groups   = ["system:masters"]
  }
]

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::881307377501:user/terraformUser"
      username = "user1"
      groups   = ["system:masters"]
    }
  ]
}
 