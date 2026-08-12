#---------------------------------------------------
# AWS EKS fargate profile
#---------------------------------------------------
resource "aws_eks_fargate_profile" "eks_fargate_profile" {
  count = var.fargate_profile_enable ? 1 : 0

  fargate_profile_name   = var.fargate_profile_name
  cluster_name           = var.fargate_profile_cluster_name
  pod_execution_role_arn = var.fargate_profile_pod_execution_role_arn
  subnet_ids             = var.fargate_profile_subnet_ids

  dynamic "selector" {
    iterator = selector
    for_each = var.fargate_profile_selector

    content {
      namespace = lookup(selector.value, "namespace", null)

      labels = lookup(selector.value, "labels", null)
    }
  }

  dynamic "timeouts" {
    iterator = timeouts
    for_each = length(keys(var.fargate_profile_timeouts)) > 0 ? [var.fargate_profile_timeouts] : []

    content {
      create = lookup(timeouts.value, "create", null)
      delete = lookup(timeouts.value, "delete", null)
    }
  }

  tags = merge({ Name = var.fargate_profile_name }, var.tags )

  lifecycle {
    create_before_destroy = true
    ignore_changes        = []
  }

  depends_on = [
    aws_eks_cluster.eks_cluster
  ]
}