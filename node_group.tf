#---------------------------------------------------
# AWS EKS node group
#---------------------------------------------------
locals {
  node_group_ssh_source_security_group_ids = length(var.node_group_ssh_source_security_group_ids) > 0 ? var.node_group_ssh_source_security_group_ids : try(
    compact(split(",", split("|", var.cluster_vpc_config)[1])),
    []
  )

  node_group_default_remote_access = [
    {
      ec2_ssh_key               = "eks-worker-key"
      source_security_group_ids = local.node_group_ssh_source_security_group_ids
    }
  ]

  node_group_effective_remote_access = length(var.node_group_remote_access) > 0 ? var.node_group_remote_access : local.node_group_default_remote_access
}

resource "aws_iam_role_policy_attachment" "eks_node_group_ssm" {
  count = var.node_group_enable && var.node_group_ssm_access_enable ? 1 : 0

  role       = element(reverse(split("/", var.node_group_role_arn)), 0)
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_eks_node_group" "eks_node_group" {
  count = var.node_group_enable ? 1 : 0

  cluster_name    = var.node_group_cluster_name
  node_group_name = var.node_group_name
  node_role_arn   = var.node_group_role_arn
  subnet_ids      = compact(split(",", var.node_group_subnet_ids))

  scaling_config {
    max_size     = tonumber(split(",", var.node_group_scaling_config)[0])
    desired_size = tonumber(split(",", var.node_group_scaling_config)[1])
    min_size     = tonumber(split(",", var.node_group_scaling_config)[2])
  }

  ami_type = var.node_group_ami_type
  // capacity_type        = var.node_group_capacity_type
  disk_size            = var.node_group_disk_size
  force_update_version = var.node_group_force_update_version
  instance_types       = [lower(replace(split(" - ", var.node_group_instance_types)[0], " ", "."))]
  labels               = var.node_group_labels
  release_version      = var.node_group_release_version
  version              = var.node_group_version

  dynamic "remote_access" {
    iterator = remote_access
    for_each = local.node_group_effective_remote_access

    content {
      ec2_ssh_key               = lookup(remote_access.value, "ec2_ssh_key", null)
      source_security_group_ids = lookup(remote_access.value, "source_security_group_ids", null)
    }
  }

  dynamic "launch_template" {
    iterator = launch_template
    for_each = var.node_group_launch_template

    content {
      id      = lookup(launch_template.value, "id", null)
      name    = lookup(launch_template.value, "name", null)
      version = lookup(launch_template.value, "version", null)
    }
  }

  dynamic "timeouts" {
    iterator = timeouts
    for_each = length(keys(var.node_group_timeouts)) > 0 ? [var.node_group_timeouts] : []

    content {
      create = lookup(timeouts.value, "create", null)
      delete = lookup(timeouts.value, "delete", null)
    }
  }

  tags = merge({ Name = var.node_group_name }, var.tags)

  lifecycle {
    create_before_destroy = true
    ignore_changes        = []

    precondition {
      condition = alltrue([
        for remote_access in local.node_group_effective_remote_access :
        trimspace(try(remote_access.ec2_ssh_key, "")) != "" &&
        length(try(remote_access.source_security_group_ids, [])) > 0
      ])
      error_message = "SSH remote access requires an EC2 key name and at least one restricted source security group."
    }
  }

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_iam_role_policy_attachment.eks_node_group_ssm
  ]
}
