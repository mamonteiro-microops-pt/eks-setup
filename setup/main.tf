terraform {
  required_version = "~> 1.4.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.60.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.5.1"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = "${path.module}/kubeconfig_${aws_eks_cluster.eks-kafka-cluster.id}.yaml"
  }
}

resource "aws_eks_cluster" "eks-kafka-cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_master_role.arn

  vpc_config {
    subnet_ids              = module.eks-vpc.public_subnets
    endpoint_private_access = false
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  kubernetes_network_config {
    service_ipv4_cidr = "172.16.0.0/12"
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKSVPCResourceController,
  ]
}

resource "aws_eks_node_group" "eks_ng_public" {
  cluster_name    = aws_eks_cluster.eks-kafka-cluster.name
  node_group_name = "kafka-public"
  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
  subnet_ids      = module.eks-vpc.public_subnets
  version         = var.cluster_version

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.medium"]
  disk_size      = 20

  # remote_access {
  #   ec2_ssh_key = "ec2-terraform-key"
  # }
  
  scaling_config {
    desired_size = 3
    min_size     = 3
    max_size     = 3
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly,
  ]

  tags = {
    "Name" = "public-node-group"
  }
}

module "argocd" {
  source = "./argocd"
  depends_on = [
    aws_eks_cluster.eks-kafka-cluster
  ]
}


# CREATE KUBECONFIG FILE
locals {
  kubeconfig = {
    apiVersion = "v1"
    kind       = "Config"
    clusters = [
      {
        name = aws_eks_cluster.eks-kafka-cluster.id
        cluster = {
          server                   = aws_eks_cluster.eks-kafka-cluster.endpoint
          certificate-authority-data = aws_eks_cluster.eks-kafka-cluster.certificate_authority.0.data
        }
      }
    ]
    contexts = [
      {
        name = aws_eks_cluster.eks-kafka-cluster.id
        context = {
          cluster = aws_eks_cluster.eks-kafka-cluster.id
          user    = "aws"
        }
      }
    ]
    current-context = aws_eks_cluster.eks-kafka-cluster.id
    users = [
      {
        name = "aws"
        user = {
          exec = {
            apiVersion = "client.authentication.k8s.io/v1alpha1"
            command    = "aws"
            args = [
              "eks",
              "get-token",
              "--region",
              "us-east-1",
              "--cluster-name",
              aws_eks_cluster.eks-kafka-cluster.id,
            ]
          }
        }
      }
    ]
  }
}

resource "local_file" "kubeconfig" {
  content  = yamlencode(local.kubeconfig)
  filename = "${path.module}/kubeconfig_${aws_eks_cluster.eks-kafka-cluster.id}.yaml"

  depends_on = [aws_eks_cluster.eks-kafka-cluster]
}

# resource "aws_eks_node_group" "eks_ng_private" {
#   cluster_name    = aws_eks_cluster.eks-kafka-cluster.name
#   node_group_name = "kafka-private"
#   node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
#   subnet_ids      = module.eks-vpc.private_subnets
#   version         = var.cluster_version

#   capacity_type  = "ON_DEMAND"
#   instance_types = ["t3.medium"]
#   disk_size      = 20

#   remote_access {
#     ec2_ssh_key = "ec2-terraform-key"
#   }

#   scaling_config {
#     desired_size = 1
#     min_size     = 1
#     max_size     = 2
#   }

#   update_config {
#     max_unavailable = 1
#   }

#   # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
#   # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
#   depends_on = [
#     aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
#     aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
#     aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly,
#   ]

#   tags = {
#     "Name" = "private-node-group"
#   }
# }