#---------------------------------------------------
# AWS EKS cluster
#---------------------------------------------------
output "cluster_id" {
  description = "The name of the cluster."
  value       = element(concat(aws_eks_cluster.eks_cluster.*.id, [""], ), 0)
}

output "cluster_name" {
  description = "Scalar EKS cluster name for Morpheus post-provision integration."
  value       = try(aws_eks_cluster.eks_cluster[0].name, "")
}

output "cluster_region" {
  description = "AWS region containing the EKS cluster."
  value       = coalesce(var.aws_region, var.region)
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster."
  value       = element(concat(aws_eks_cluster.eks_cluster.*.arn, [""], ), 0)
}

output "cluster_endpoint" {
  description = "The endpoint for your Kubernetes API server."
  value       = concat(aws_eks_cluster.eks_cluster.*.endpoint, [""], )
}

output "cluster_endpoint_value" {
  description = "Scalar Kubernetes API endpoint for Morpheus post-provision integration."
  value       = try(aws_eks_cluster.eks_cluster[0].endpoint, "")
}

output "cluster_identity" {
  description = "Nested attribute containing identity provider information for your cluster. Only available on Kubernetes version 1.13 and 1.14 clusters created or upgraded on or after September 3, 2019."
  value       = concat(aws_eks_cluster.eks_cluster.*.identity, [""], )
}

output "cluster_platform_version" {
  description = "The platform version for the cluster."
  value       = element(concat(aws_eks_cluster.eks_cluster.*.platform_version, [""], ), 0)
}

output "cluster_status" {
  description = "TThe status of the EKS cluster. One of CREATING, ACTIVE, DELETING, FAILED."
  value       = element(concat(aws_eks_cluster.eks_cluster.*.status, [""], ), 0)
}

output "cluster_version" {
  description = "The Kubernetes server version for the cluster."
  value       = element(concat(aws_eks_cluster.eks_cluster.*.version, [""], ), 0)
}

output "cluster_certificate_authority" {
  description = "Nested attribute containing certificate-authority-data for your cluster."
  value       = concat(aws_eks_cluster.eks_cluster.*.certificate_authority, [""], )
}

output "cluster_certificate_authority_data" {
  description = "Base64-encoded cluster CA data for Morpheus post-provision integration."
  value       = try(aws_eks_cluster.eks_cluster[0].certificate_authority[0].data, "")
}

output "cluster_vpc_config" {
  description = "Additional nested attributes"
  value       = concat(aws_eks_cluster.eks_cluster.*.vpc_config, [""], )
}

#---------------------------------------------------
# AWS EKS fargate profile
#---------------------------------------------------
output "fargate_profile_arn" {
  description = "Amazon Resource Name (ARN) of the EKS Fargate Profile."
  value       = element(concat(aws_eks_fargate_profile.eks_fargate_profile.*.arn, [""], ), 0)
}

output "fargate_profile_id" {
  description = "EKS Cluster name and EKS Fargate Profile name separated by a colon (:)."
  value       = element(concat(aws_eks_fargate_profile.eks_fargate_profile.*.id, [""], ), 0)
}

output "fargate_profile_status" {
  description = "Status of the EKS Fargate Profile."
  value       = element(concat(aws_eks_fargate_profile.eks_fargate_profile.*.status, [""], ), 0)
}

#---------------------------------------------------
# AWS EKS node group
#---------------------------------------------------
output "node_group_arn" {
  description = "Amazon Resource Name (ARN) of the EKS Node Group."
  value       = element(concat(aws_eks_node_group.eks_node_group.*.arn, [""], ), 0)
}

output "node_group_id" {
  description = "EKS Cluster name and EKS Node Group name separated by a colon (:)."
  value       = element(concat(aws_eks_node_group.eks_node_group.*.id, [""], ), 0)
}

output "node_group_status" {
  description = "Status of the EKS Node Group."
  value       = element(concat(aws_eks_node_group.eks_node_group.*.status, [""], ), 0)
}

output "node_group_resources" {
  description = "List of objects containing information about underlying resources."
  value       = concat(aws_eks_node_group.eks_node_group.*.resources, [""], )
}