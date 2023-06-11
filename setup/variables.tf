variable "cluster_name" {
  description = "kubernetes cluster name"
  default     = "eks-kafka-cluster"
}

variable "cluster_version" {
  default = "1.27"
}