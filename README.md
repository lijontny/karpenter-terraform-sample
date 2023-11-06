# Terraform EKS Karpenter
## Input
- accountID
- certificate_ca - Certificate authority (it is available in AWS EKS console)
- eks_worker_node_role_arn - Current Worker node ARN
- subnet_ids - List of private subnets where you want to deploy karpenter nodes
```shell
["subnet-123","subnet-321"]
```
- security_groups - List of security groups for Karpenter (you can use current worker node SG)
```shell
["sg-123"]
```
- cluster_name - EKS cluster name
- cluster_endpoint - EKS Cluster endpoint
```shell
aws eks describe-cluster --name primaryeks --query cluster.endpoint --output text
```
- cluster_version - K8s Version
- oidc_provider_arn - 
OIDC
```shell
cluster_name=<cluster_name>
oidc_id=$(aws eks describe-cluster --name $cluster_name --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)
echo $oidc_id
aws iam list-open-id-connect-providers --output text | cut -f 2 | grep $oidc_id
```

## Prerequisites

1. Kubeconfig path environment file
```shell
export KUBE_CONFIG_PATH= ~/.kube/kubeconfig
```

2. Create an IAM OIDC identity provider for your cluster with the following command.
```shell
eksctl utils associate-iam-oidc-provider --cluster $cluster_name --approve
```
3. EKS cluster (version 1.28)
4. EBS CSI Addon

## Sample Pod Deployment to karpenter nodes 
```shell
kubectl apply -f sample-pod.yaml
kubectl scale deployment inflate --replicas 5
kubectl logs -f -n karpenter -l app.kubernetes.io/name=karpenter -c controller
```
## Deployment
```shell
terraform init
terraform plan
terraform apply
```
