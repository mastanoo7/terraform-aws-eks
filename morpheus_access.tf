terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.32"
    }
  }
}


provider "kubernetes" {
  host = var.cluster_enable ? aws_eks_cluster.eks_cluster[0].endpoint : "https://127.0.0.1"

  cluster_ca_certificate = var.cluster_enable ? base64decode(
    aws_eks_cluster.eks_cluster[0].certificate_authority[0].data
  ) : ""

  # Generate credentials when the Kubernetes client connects. A static
  # aws_eks_cluster_auth token can expire while EKS is still provisioning.
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      var.cluster_enable ? aws_eks_cluster.eks_cluster[0].name : "",
      "--region",
      var.region
    ]
  }
}


resource "kubernetes_service_account_v1" "morpheus" {
  count = var.cluster_enable ? 1 : 0


  metadata {
    name      = "morpheus"
    namespace = "kube-system"
  }


  # The Kubernetes provider authenticates as the AWS principal running
  # Terraform. Ensure its EKS access policy is active before contacting the
  # Kubernetes API, otherwise a parallel first apply can fail with 401.
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
