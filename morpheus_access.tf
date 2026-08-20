terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.32"
    }
  }
}

data "aws_eks_cluster_auth" "morpheus" {
  count = var.cluster_enable ? 1 : 0
  name  = aws_eks_cluster.eks_cluster[0].name

  # Force token generation during apply, after EKS and its access policy
  # are ready. This avoids both token expiry and an AWS CLI dependency.
  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_eks_access_policy_association.cluster_access,
  ]
}

provider "kubernetes" {
  host = var.cluster_enable ? aws_eks_cluster.eks_cluster[0].endpoint : "https://127.0.0.1"
  cluster_ca_certificate = var.cluster_enable ? base64decode(
    aws_eks_cluster.eks_cluster[0].certificate_authority[0].data
  ) : ""
  token = var.cluster_enable ? data.aws_eks_cluster_auth.morpheus[0].token : ""
}

resource "kubernetes_service_account_v1" "morpheus" {
  count = var.cluster_enable ? 1 : 0

  metadata {
    name      = "morpheus"
    namespace = "kube-system"
  }

  depends_on = [
    aws_eks_access_policy_association.cluster_access
  ]
}

resource "kubernetes_cluster_role_binding_v1" "morpheus_admin" {
  count = var.cluster_enable ? 1 : 0

  metadata {
    name = "morpheus-cluster-admin"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.morpheus[0].metadata[0].name
    namespace = kubernetes_service_account_v1.morpheus[0].metadata[0].namespace
  }
}

resource "kubernetes_secret_v1" "morpheus_token" {
  count = var.cluster_enable ? 1 : 0

  metadata {
    name      = "morpheus-token"
    namespace = kubernetes_service_account_v1.morpheus[0].metadata[0].namespace
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account_v1.morpheus[0].metadata[0].name
    }
  }

  type = "kubernetes.io/service-account-token"

  depends_on = [
    kubernetes_cluster_role_binding_v1.morpheus_admin
  ]
}

output "morpheus_service_account_token" {
  description = "Bearer token used by Morpheus to access the EKS cluster."
  value       = try(kubernetes_secret_v1.morpheus_token[0].data["token"], "")
  sensitive   = true
}

output "morpheus_kubeconfig" {
  description = "Kubeconfig used to register the EKS cluster in Morpheus."
  sensitive   = true

  value = var.cluster_enable ? yamlencode({
    apiVersion = "v1"
    kind       = "Config"
    clusters = [{
      name = aws_eks_cluster.eks_cluster[0].name
      cluster = {
        server                     = aws_eks_cluster.eks_cluster[0].endpoint
        certificate-authority-data = aws_eks_cluster.eks_cluster[0].certificate_authority[0].data
      }
    }]
    contexts = [{
      name = aws_eks_cluster.eks_cluster[0].name
      context = {
        cluster = aws_eks_cluster.eks_cluster[0].name
        user    = "morpheus"
      }
    }]
    current-context = aws_eks_cluster.eks_cluster[0].name
    users = [{
      name = "morpheus"
      user = {
        token = try(kubernetes_secret_v1.morpheus_token[0].data["token"], "")
      }
    }]
  }) : ""
}
