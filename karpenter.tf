module "eks_blueprints_addons" {
  source = "aws-ia/eks-blueprints-addons/aws"
  version = "1.16.3"

  cluster_name      = var.cluster_name
  cluster_endpoint  = var.cluster_endpoint
  cluster_version   = var.cluster_version
  oidc_provider_arn = var.oidc_provider_arn
  enable_karpenter  = true
  karpenter = {
    repository_username = data.aws_ecrpublic_authorization_token.token.user_name
    repository_password = data.aws_ecrpublic_authorization_token.token.password
  }
}

resource "aws_eks_access_entry" "linux" {
  cluster_name      = var.cluster_name
  principal_arn     = module.eks_blueprints_addons.karpenter.node_iam_role_arn
  type              = "EC2_LINUX"
}