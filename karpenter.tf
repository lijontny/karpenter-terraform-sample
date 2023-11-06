## required subnet tags for karpenter
resource "aws_ec2_tag" "karpenter_subnet_tags" {
  for_each    = var.subnet_ids
  resource_id = each.value
  key         = "karpenter.sh/discovery"
  value       = format("%s", var.cluster_name)
}
resource "aws_ec2_tag" "karpenter_sg_tags" {
  for_each    = var.security_groups
  resource_id = each.value
  key         = "karpenter.sh/discovery"
  value       =  format("%s", var.cluster_name)
}

module "eks_blueprints_addons" {
  source = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.11.0" #ensure to update this to the latest/desired version

  cluster_name      = var.cluster_name
  cluster_endpoint  = var.cluster_endpoint
  cluster_version   = var.cluster_version
  oidc_provider_arn = var.oidc_provider_arn
  enable_karpenter  = true
  karpenter = {
    repository_username = data.aws_ecrpublic_authorization_token.token.user_name
    repository_password = data.aws_ecrpublic_authorization_token.token.password
  }
  eks_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }
}