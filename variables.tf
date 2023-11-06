variable "accountID" {
  type = string
}
variable "certificate_ca" {
  type = string
}

variable "eks_worker_node_role_arn" {
}

variable "subnet_ids" {
  type = set(string)
}

variable "security_groups" {
  type = set(string)
}

variable "cluster_name" {
}

variable "cluster_endpoint" {
}

variable "cluster_version" {
  default = "1.28"
}

variable "oidc_provider_arn" {
}