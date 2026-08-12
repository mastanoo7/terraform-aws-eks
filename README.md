## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eks_cluster.eks_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) | resource |
| [aws_eks_fargate_profile.eks_fargate_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_fargate_profile) | resource |
| [aws_eks_node_group.eks_node_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_enable"></a> [cluster\_enable](#input\_cluster\_enable) | Enable creating AWS EKS cluster | `bool` | `true` | no |
| <a name="input_cluster_enabled_cluster_log_types"></a> [cluster\_enabled\_cluster\_log\_types](#input\_cluster\_enabled\_cluster\_log\_types) | (Optional) A list of the desired control plane logging to enable. For more information, see Amazon EKS Control Plane Logging | `list` | `[]` | no |
| <a name="input_cluster_encryption_config"></a> [cluster\_encryption\_config](#input\_cluster\_encryption\_config) | (Optional) Configuration block with encryption configuration for the cluster. Only available on Kubernetes 1.13 and above clusters created after March 6, 2020. | `list` | `[]` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Custom name of the cluster. | `string` | `""` | no |
| <a name="input_cluster_role_arn"></a> [cluster\_role\_arn](#input\_cluster\_role\_arn) | (Required) The Amazon Resource Name (ARN) of the IAM role that provides permissions for the Kubernetes control plane to make calls to AWS API operations on your behalf. | `string` | `""` | no |
| <a name="input_cluster_timeouts"></a> [cluster\_timeouts](#input\_cluster\_timeouts) | Set timeouts for EKS cluster | `map` | `{}` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | (Optional) Desired Kubernetes master version. If you do not specify a value, the latest available version at resource creation is used and no upgrades will occur except those automatically triggered by EKS. The value must be configured and increased to upgrade the version when desired. Downgrades are not supported by EKS. | `any` | `null` | no |
| <a name="input_cluster_vpc_config"></a> [cluster\_vpc\_config](#input\_cluster\_vpc\_config) | (Required) Nested argument for the VPC associated with your cluster. Amazon EKS VPC resources have specific requirements to work properly with Kubernetes. For more information, see Cluster VPC Considerations and Cluster Security Group Considerations in the Amazon EKS User Guide. | `list` | `[]` | no |
| <a name="input_fargate_profile_cluster_name"></a> [fargate\_profile\_cluster\_name](#input\_fargate\_profile\_cluster\_name) | Name of the EKS Cluster. | `string` | `""` | no |
| <a name="input_fargate_profile_enable"></a> [fargate\_profile\_enable](#input\_fargate\_profile\_enable) | Enable EKS fargate profile usage | `bool` | `false` | no |
| <a name="input_fargate_profile_name"></a> [fargate\_profile\_name](#input\_fargate\_profile\_name) | Name of the EKS Fargate Profile. | `string` | `""` | no |
| <a name="input_fargate_profile_pod_execution_role_arn"></a> [fargate\_profile\_pod\_execution\_role\_arn](#input\_fargate\_profile\_pod\_execution\_role\_arn) | (Required) Amazon Resource Name (ARN) of the IAM Role that provides permissions for the EKS Fargate Profile. | `string` | `""` | no |
| <a name="input_fargate_profile_selector"></a> [fargate\_profile\_selector](#input\_fargate\_profile\_selector) | (Required) Configuration block(s) for selecting Kubernetes Pods to execute with this EKS Fargate Profile. | `list` | `[]` | no |
| <a name="input_fargate_profile_subnet_ids"></a> [fargate\_profile\_subnet\_ids](#input\_fargate\_profile\_subnet\_ids) | (Required) Identifiers of private EC2 Subnets to associate with the EKS Fargate Profile. These subnets must have the following resource tag: kubernetes.io/cluster/CLUSTER\_NAME (where CLUSTER\_NAME is replaced with the name of the EKS Cluster). | `list` | `[]` | no |
| <a name="input_fargate_profile_timeouts"></a> [fargate\_profile\_timeouts](#input\_fargate\_profile\_timeouts) | Set timeouts for EKS fargate profile | `map` | `{}` | no |
| <a name="input_node_group_ami_type"></a> [node\_group\_ami\_type](#input\_node\_group\_ami\_type) | (Optional) Type of Amazon Machine Image (AMI) associated with the EKS Node Group. Defaults to AL2\_x86\_64. Valid values: AL2\_x86\_64, AL2\_x86\_64\_GPU. Terraform will only perform drift detection if a configuration value is provided. | `string` | `"AL2_x86_64"` | no |
| <a name="input_node_group_cluster_name"></a> [node\_group\_cluster\_name](#input\_node\_group\_cluster\_name) | Name of the EKS Cluster. | `string` | `""` | no |
| <a name="input_node_group_disk_size"></a> [node\_group\_disk\_size](#input\_node\_group\_disk\_size) | (Optional) Disk size in GiB for worker nodes. Defaults to 20. Terraform will only perform drift detection if a configuration value is provided. | `number` | `20` | no |
| <a name="input_node_group_enable"></a> [node\_group\_enable](#input\_node\_group\_enable) | Enable EKS node group usage | `bool` | `false` | no |
| <a name="input_node_group_force_update_version"></a> [node\_group\_force\_update\_version](#input\_node\_group\_force\_update\_version) | (Optional) Force version update if existing pods are unable to be drained due to a pod disruption budget issue. | `any` | `null` | no |
| <a name="input_node_group_instance_types"></a> [node\_group\_instance\_types](#input\_node\_group\_instance\_types) | (Optional) Set of instance types associated with the EKS Node Group. Defaults to ['t3.medium']. Terraform will only perform drift detection if a configuration value is provided. Currently, the EKS API only accepts a single value in the set. | `list` | <pre>[<br>  "t3.medium"<br>]</pre> | no |
| <a name="input_node_group_labels"></a> [node\_group\_labels](#input\_node\_group\_labels) | (Optional) Key-value mapping of Kubernetes labels. Only labels that are applied with the EKS API are managed by this argument. Other Kubernetes labels applied to the EKS Node Group will not be managed. | `map(string)` | `{}` | no |
| <a name="input_node_group_launch_template"></a> [node\_group\_launch\_template](#input\_node\_group\_launch\_template) | (Optional) Configuration block with Launch Template settings. | `list` | `[]` | no |
| <a name="input_node_group_name"></a> [node\_group\_name](#input\_node\_group\_name) | Name of the EKS Node Group. | `string` | `""` | no |
| <a name="input_node_group_release_version"></a> [node\_group\_release\_version](#input\_node\_group\_release\_version) | (Optional) AMI version of the EKS Node Group. Defaults to latest version for Kubernetes version. | `any` | `null` | no |
| <a name="input_node_group_remote_access"></a> [node\_group\_remote\_access](#input\_node\_group\_remote\_access) | (Optional) Configuration block with remote access settings. | `list` | `[]` | no |
| <a name="input_node_group_role_arn"></a> [node\_group\_role\_arn](#input\_node\_group\_role\_arn) | (Required) Amazon Resource Name (ARN) of the IAM Role that provides permissions for the EKS Node Group. | `string` | `""` | no |
| <a name="input_node_group_scaling_config"></a> [node\_group\_scaling\_config](#input\_node\_group\_scaling\_config) | n/a | `list` | <pre>[<br>  {<br>    "desired_size": 1,<br>    "max_size": 1,<br>    "min_size": 1<br>  }<br>]</pre> | no |
| <a name="input_node_group_subnet_ids"></a> [node\_group\_subnet\_ids](#input\_node\_group\_subnet\_ids) | (Required) Identifiers of EC2 Subnets to associate with the EKS Node Group. These subnets must have the following resource tag: kubernetes.io/cluster/CLUSTER\_NAME (where CLUSTER\_NAME is replaced with the name of the EKS Cluster). | `list` | `[]` | no |
| <a name="input_node_group_timeouts"></a> [node\_group\_timeouts](#input\_node\_group\_timeouts) | Set timeouts for EKS node group | `map` | `{}` | no |
| <a name="input_node_group_version"></a> [node\_group\_version](#input\_node\_group\_version) | (Optional) Kubernetes version. Defaults to EKS Cluster Kubernetes version. Terraform will only perform drift detection if a configuration value is provided. | `any` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | The region where to deploy this code (e.g. us-east-1). | `string` | `"ap-southeast-1"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A list of tag blocks. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | The Amazon Resource Name (ARN) of the cluster. |
| <a name="output_cluster_certificate_authority"></a> [cluster\_certificate\_authority](#output\_cluster\_certificate\_authority) | Nested attribute containing certificate-authority-data for your cluster. |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | The endpoint for your Kubernetes API server. |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | The name of the cluster. |
| <a name="output_cluster_identity"></a> [cluster\_identity](#output\_cluster\_identity) | Nested attribute containing identity provider information for your cluster. Only available on Kubernetes version 1.13 and 1.14 clusters created or upgraded on or after September 3, 2019. |
| <a name="output_cluster_platform_version"></a> [cluster\_platform\_version](#output\_cluster\_platform\_version) | The platform version for the cluster. |
| <a name="output_cluster_status"></a> [cluster\_status](#output\_cluster\_status) | TThe status of the EKS cluster. One of CREATING, ACTIVE, DELETING, FAILED. |
| <a name="output_cluster_version"></a> [cluster\_version](#output\_cluster\_version) | The Kubernetes server version for the cluster. |
| <a name="output_cluster_vpc_config"></a> [cluster\_vpc\_config](#output\_cluster\_vpc\_config) | Additional nested attributes |
| <a name="output_fargate_profile_arn"></a> [fargate\_profile\_arn](#output\_fargate\_profile\_arn) | Amazon Resource Name (ARN) of the EKS Fargate Profile. |
| <a name="output_fargate_profile_id"></a> [fargate\_profile\_id](#output\_fargate\_profile\_id) | EKS Cluster name and EKS Fargate Profile name separated by a colon (:). |
| <a name="output_fargate_profile_status"></a> [fargate\_profile\_status](#output\_fargate\_profile\_status) | Status of the EKS Fargate Profile. |
| <a name="output_node_group_arn"></a> [node\_group\_arn](#output\_node\_group\_arn) | Amazon Resource Name (ARN) of the EKS Node Group. |
| <a name="output_node_group_id"></a> [node\_group\_id](#output\_node\_group\_id) | EKS Cluster name and EKS Node Group name separated by a colon (:). |
| <a name="output_node_group_resources"></a> [node\_group\_resources](#output\_node\_group\_resources) | List of objects containing information about underlying resources. |
| <a name="output_node_group_status"></a> [node\_group\_status](#output\_node\_group\_status) | Status of the EKS Node Group. |
#   t e r r a f o r m - a w s - e k s  
 