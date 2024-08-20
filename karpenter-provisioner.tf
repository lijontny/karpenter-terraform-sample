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
              values: ["t", "c", "m"]
            - key: kubernetes.io/arch
              operator: In
              values: ["amd64"]
            - key: "karpenter.sh/capacity-type"
              operator: In
              values: ["on-demand"]
            - key: kubernetes.io/os
              operator: In
              values: ["linux"]
            - key: "karpenter.k8s.aws/instance-family"
              operator: In
              values: ["m6"]
          nodeClassRef:
            name: default
          taints:
            - key: "compute"
              value: "maxsize"
              effect: "NoSchedule"
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

