# AWS_Auth Configuration
resource "kubectl_manifest" "eks_aws_auth" {
  yaml_body = <<-YAML
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: aws-auth
      namespace: kube-system
    data:
      mapRoles: |
        - groups:
          - system:bootstrappers
          - system:nodes
          rolearn: ${var.eks_worker_node_role_arn}
          username: system:node:{{EC2PrivateDNSName}}
        - groups:
          - system:bootstrappers
          - system:nodes
          rolearn: ${module.eks_blueprints_addons.karpenter.node_iam_role_arn}
          username: system:node:{{EC2PrivateDNSName}}
  YAML
}

# nodepool
resource "kubectl_manifest" "karpenter_nodepool" {
  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1beta1
    kind: NodePool
    metadata:
      name: default
    spec:
      template:
        spec:
          requirements:
            - key: "karpenter.k8s.aws/instance-category"
              operator: In
              values: ["c", "m"]
            - key: "karpenter.k8s.aws/instance-cpu"
              operator: In
              values: ["8", "16", "32"]
            - key: "karpenter.k8s.aws/instance-hypervisor"
              operator: In
              values: ["nitro"]
            - key: "kubernetes.io/arch"
              operator: In
              values: ["amd64"]
            - key: "karpenter.sh/capacity-type"
              operator: In
              values: ["on-demand"]
          nodeClassRef:
            name: default
  YAML
  depends_on = [
    module.eks_blueprints_addons
  ]
}
# nodeclass
resource "kubectl_manifest" "karpenter_nodeclass" {
  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1beta1
    kind: EC2NodeClass
    metadata:
      name: default
    spec:
      amiFamily: AL2 # Amazon Linux 2
      subnetSelectorTerms:
        - tags:
            karpenter.sh/discovery: "${var.cluster_name}"
      securityGroupSelectorTerms:
        - tags:
            karpenter.sh/discovery: "${var.cluster_name}"
      role: ${module.eks_blueprints_addons.karpenter.node_iam_role_name}
      tags:
        karpenter.sh/discovery: "${var.cluster_name}"
  YAML
}

