# Generate a short-lived EKS authentication token after the cluster and its
# access policy are ready. The post-provision task uses this token only to
# create the persistent Morpheus service account and kubeconfig.
data "aws_eks_cluster_auth" "morpheus_bootstrap" {
  count = var.cluster_enable ? 1 : 0
  name  = aws_eks_cluster.eks_cluster[0].name

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_eks_access_policy_association.cluster_access,
  ]
}

output "morpheus_eks_bootstrap_token" {
  description = "Short-lived EKS token used only by the Morpheus post-provision task."
  value       = try(data.aws_eks_cluster_auth.morpheus_bootstrap[0].token, "")
  sensitive   = true
}
