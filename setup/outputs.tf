output "cluster_id" {
    description = "id of the cluster"
    value = aws_eks_cluster.eks-kafka-cluster.id
}