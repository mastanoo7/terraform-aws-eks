#-----------------------------------------------------------
# Global or/and default variables
#-----------------------------------------------------------
variable "region" {
  description = "The region where to deploy this code (e.g. us-east-1)."
  default     = null
}

variable "access_key" {
  description = "AWS access key supplied by the Morpheus Terraform Cloud Profile."
  type        = string
  sensitive   = true
  default     = null
}

variable "secret_key" {
  description = "AWS secret key supplied by the Morpheus Terraform Cloud Profile."
  type        = string
  sensitive   = true
  default     = null
}

variable "aws_region" {
  description = "AWS region supplied by the Morpheus Terraform Cloud Profile."
  type        = string
  default     = null
}

variable "aws_profile" {
  description = "Optional shared AWS credentials profile name."
  type        = string
  default     = null
}

variable "tags" {
  description = "A list of tag blocks."
  type        = map(string)
  default     = {}
}

#-----------------------------------------------------------
# AWS EKS cluster
#-----------------------------------------------------------
variable "cluster_enable" {
  description = "Enable creating AWS EKS cluster"
  default     = false
}

variable "cluster_name" {
  description = "Custom name of the cluster."
  default     = ""
}

variable "cluster_role_arn" {
  description = "(Required) The Amazon Resource Name (ARN) of the IAM role that provides permissions for the Kubernetes control plane to make calls to AWS API operations on your behalf."
  default     = ""
}

variable "cluster_enabled_cluster_log_types" {
  description = "(Optional) A list of the desired control plane logging to enable. For more information, see Amazon EKS Control Plane Logging"
  default     = []
}

variable "cluster_version" {
  description = "(Optional) Desired Kubernetes master version. If you do not specify a value, the latest available version at resource creation is used and no upgrades will occur except those automatically triggered by EKS. The value must be configured and increased to upgrade the version when desired. Downgrades are not supported by EKS."
  default     = null
}

variable "cluster_vpc_config" {
  description = "Morpheus-safe format: subnet1,subnet2|security-group-id"
  type        = string
  default     = ""

  validation {
    condition = var.cluster_vpc_config == "" || try(
      length(split("|", var.cluster_vpc_config)) == 2 &&
      length(compact(split(",", split("|", var.cluster_vpc_config)[0]))) >= 2 &&
      length(compact(split(",", split("|", var.cluster_vpc_config)[1]))) >= 1,
      false
    )
    error_message = "cluster_vpc_config must use subnet1,subnet2|security-group-id format."
  }
}

variable "cluster_encryption_config" {
  description = "(Optional) Configuration block with encryption configuration for the cluster. Only available on Kubernetes 1.13 and above clusters created after March 6, 2020."
  default     = []
}

// variable "cluster_kubernetes_network_config" {
//   description = "(Optional) Configuration block with kubernetes network configuration for the cluster. If removed, Terraform will only perform drift detection if a configuration value is provided."
//   default     = []
// }

variable "cluster_timeouts" {
  description = "Set timeouts for EKS cluster"
  default     = {}
}

variable "cluster_access_policy_arn" {
  description = "IAM policy ARN to associate with the EKS cluster access entry for console and workload visibility. Default is the admin policy needed to view workloads in the AWS console."
  type        = string
  default     = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
}

variable "cluster_access_entries" {
  description = "List of IAM principals that should be allowed to access the cluster. Use reserved system:* Kubernetes groups is not allowed in EKS access entries; leave kubernetes_groups unset or use custom groups only. The cluster access policy provides the console admin permissions."
  type        = list(any)
  default = [
    {
      principal_arn = "arn:aws:iam::634222034927:user/suman"
      type          = "STANDARD"
    }
  ]
}

#---------------------------------------------------
# AWS EKS fargate profile
#---------------------------------------------------
variable "fargate_profile_enable" {
  description = "Enable EKS fargate profile usage"
  default     = false
}

variable "fargate_profile_name" {
  description = "Name of the EKS Fargate Profile."
  default     = ""
}

variable "fargate_profile_cluster_name" {
  description = "Name of the EKS Cluster."
  default     = ""
}

variable "fargate_profile_pod_execution_role_arn" {
  description = "(Required) Amazon Resource Name (ARN) of the IAM Role that provides permissions for the EKS Fargate Profile."
  default     = ""
}

variable "fargate_profile_subnet_ids" {
  description = "(Required) Identifiers of private EC2 Subnets to associate with the EKS Fargate Profile. These subnets must have the following resource tag: kubernetes.io/cluster/CLUSTER_NAME (where CLUSTER_NAME is replaced with the name of the EKS Cluster)."
  default     = []
}

variable "fargate_profile_selector" {
  description = "(Required) Configuration block(s) for selecting Kubernetes Pods to execute with this EKS Fargate Profile. "
  default     = []
}

variable "fargate_profile_timeouts" {
  description = "Set timeouts for EKS fargate profile"
  default     = {}
}

#---------------------------------------------------
# AWS EKS node group
#---------------------------------------------------
variable "node_group_enable" {
  description = "Enable EKS node group usage"
  default     = false
}

variable "node_group_name" {
  description = "Name of the EKS Node Group."
  default     = ""
}

variable "node_group_cluster_name" {
  description = "Name of the EKS Cluster."
  default     = ""
}

variable "node_group_role_arn" {
  description = "(Required) Amazon Resource Name (ARN) of the IAM Role that provides permissions for the EKS Node Group."
  default     = ""
}

variable "node_group_ssm_access_enable" {
  description = "Attach AmazonSSMManagedInstanceCore to the EKS node IAM role so worker nodes can register with Systems Manager and use Session Manager."
  type        = bool
  default     = true
}

variable "node_group_subnet_ids" {
  description = "Comma-separated subnet IDs for the EKS Node Group."
  type        = string
  default     = ""
}

variable "node_group_scaling_config" {
  description = "Comma-separated max,desired,min node-group sizes."
  type        = string
  default     = "1,1,1"
}

variable "node_group_ami_type" {
  description = "(Optional) Type of Amazon Machine Image (AMI) associated with the EKS Node Group. Defaults to AL2_x86_64. Valid values: AL2_x86_64, AL2_x86_64_GPU. Terraform will only perform drift detection if a configuration value is provided."
  default     = "AL2_x86_64"
}

// variable "node_group_capacity_type" {
//   description = "(Optional) Type of capacity associated with the EKS Node Group. Valid values: ON_DEMAND, SPOT. Terraform will only perform drift detection if a configuration value is provided."
//   default     = null
// }

variable "node_group_disk_size" {
  description = "(Optional) Disk size in GiB for worker nodes. Defaults to 20. Terraform will only perform drift detection if a configuration value is provided."
  default     = 20
}

variable "node_group_force_update_version" {
  description = "(Optional) Force version update if existing pods are unable to be drained due to a pod disruption budget issue."
  default     = null
}

variable "node_group_instance_types" {
  description = "Morpheus plan label or EC2 instance type for the EKS Node Group."
  type        = string
  default     = "c7i-flex.large"
}

variable "node_group_labels" {
  description = "(Optional) Key-value mapping of Kubernetes labels. Only labels that are applied with the EKS API are managed by this argument. Other Kubernetes labels applied to the EKS Node Group will not be managed."
  type        = map(string)
  default     = {}
}

variable "node_group_release_version" {
  description = "(Optional) AMI version of the EKS Node Group. Defaults to latest version for Kubernetes version."
  default     = null
}

variable "node_group_version" {
  description = "(Optional) Kubernetes version. Defaults to EKS Cluster Kubernetes version. Terraform will only perform drift detection if a configuration value is provided."
  default     = null
}

variable "node_group_remote_access" {
  description = "Optional complete remote-access configuration. When empty, the hardcoded eks-worker-key and node_group_ssh_source_security_group_ids are used."
  default     = []
}

variable "node_group_ssh_source_security_group_ids" {
  description = "Security groups allowed to initiate SSH to worker nodes. When empty, the security groups from cluster_vpc_config are used."
  type        = list(string)
  default     = []
}

variable "node_group_launch_template" {
  description = "(Optional) Configuration block with Launch Template settings."
  default     = []
}

variable "node_group_timeouts" {
  description = "Set timeouts for EKS node group"
  default     = {}
}
