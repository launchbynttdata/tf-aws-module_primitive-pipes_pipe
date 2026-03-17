# Complete Example - AWS EventBridge Pipes Pipe

This example creates an EventBridge Pipes pipe that connects an SQS queue (source) to another SQS queue (target).

## Usage

```hcl
module "pipe" {
  source = "../.."

  depends_on = [aws_iam_role_policy.source, aws_iam_role_policy.target]

  name        = var.name != null ? var.name : (var.name_prefix == null ? module.resource_names["pipe"].standard : null)
  name_prefix = var.name != null ? null : var.name_prefix
  role_arn    = aws_iam_role.pipe.arn
  source_arn  = aws_sqs_queue.source.arn
  target_arn  = aws_sqs_queue.target.arn

  description         = var.description
  desired_state       = var.desired_state
  enrichment          = var.enrichment
  kms_key_identifier  = var.kms_key_identifier

  enrichment_parameters = var.enrichment_parameters
  log_configuration    = var.log_configuration
  source_parameters    = var.source_parameters
  target_parameters   = var.target_parameters

  tags = var.tags
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource_names_map | Map of resource names for the resource naming module | map(object) | See variables.tf | no |
| logical_product_family | Logical product family for resource naming | string | n/a | yes |
| logical_product_service | Logical product service for resource naming | string | n/a | yes |
| class_env | Class environment for resource naming | string | n/a | yes |
| instance_env | Instance environment number for resource naming (0-999) | number | n/a | yes |
| instance_resource | Instance resource number for resource naming (0-100) | number | n/a | yes |
| name | Name of the pipe | string | null | no |
| name_prefix | Name prefix for the pipe | string | null | no |
| description | Description of the pipe | string | "Managed by Terraform" | no |
| desired_state | Desired state (RUNNING or STOPPED) | string | "RUNNING" | no |
| enrichment | ARN of enrichment resource | string | null | no |
| kms_key_identifier | KMS key for encryption | string | null | no |
| enrichment_parameters | Enrichment parameters | object | null | no |
| log_configuration | Log configuration | object | null | no |
| source_parameters | Source parameters | any | null | no |
| target_parameters | Target parameters | any | null | no |
| tags | Resource tags | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the pipe |
| arn | The ARN of the pipe |
| name | The name of the pipe |
| desired_state | The desired state of the pipe (RUNNING or STOPPED) |
| source | The ARN of the source resource |
| target | The ARN of the target resource |
| role_arn | The ARN of the IAM role |

## Running the Example

```bash
terraform init
terraform plan -var-file=test.tfvars
terraform apply -var-file=test.tfvars
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.100 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_names"></a> [resource\_names](#module\_resource\_names) | terraform.registry.launch.nttdata.com/module_library/resource_name/launch | ~> 2.0 |
| <a name="module_pipe"></a> [pipe](#module\_pipe) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.pipe](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_kms_alias.sqs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.sqs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_sqs_queue.source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue.target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_resource_names_map"></a> [resource\_names\_map](#input\_resource\_names\_map) | Map of resource names for the resource naming module. cloud\_resource\_type must be alphanumeric (letters and numbers). | <pre>map(object({<br/>    name       = string<br/>    max_length = number<br/>  }))</pre> | <pre>{<br/>  "iam_role": {<br/>    "max_length": 64,<br/>    "name": "iamrole1"<br/>  },<br/>  "pipe": {<br/>    "max_length": 64,<br/>    "name": "pipe1"<br/>  },<br/>  "source_queue": {<br/>    "max_length": 80,<br/>    "name": "sqsqueue1"<br/>  },<br/>  "target_queue": {<br/>    "max_length": 80,<br/>    "name": "sqsqueue2"<br/>  }<br/>}</pre> | no |
| <a name="input_logical_product_family"></a> [logical\_product\_family](#input\_logical\_product\_family) | Logical product family for resource naming. | `string` | n/a | yes |
| <a name="input_logical_product_service"></a> [logical\_product\_service](#input\_logical\_product\_service) | Logical product service for resource naming. | `string` | n/a | yes |
| <a name="input_class_env"></a> [class\_env](#input\_class\_env) | Class environment for resource naming. | `string` | n/a | yes |
| <a name="input_instance_env"></a> [instance\_env](#input\_instance\_env) | Instance environment number for resource naming (0-999). | `number` | n/a | yes |
| <a name="input_instance_resource"></a> [instance\_resource](#input\_instance\_resource) | Instance resource number for resource naming (0-100). | `number` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the pipe. Conflicts with name\_prefix. | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Name prefix for the pipe. Conflicts with name. | `string` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the pipe. | `string` | `"Managed by Terraform"` | no |
| <a name="input_desired_state"></a> [desired\_state](#input\_desired\_state) | Desired state of the pipe (RUNNING or STOPPED). | `string` | `"RUNNING"` | no |
| <a name="input_enrichment"></a> [enrichment](#input\_enrichment) | ARN of an enrichment resource. | `string` | `null` | no |
| <a name="input_kms_key_identifier"></a> [kms\_key\_identifier](#input\_kms\_key\_identifier) | KMS key for pipe encryption. | `string` | `null` | no |
| <a name="input_enrichment_parameters"></a> [enrichment\_parameters](#input\_enrichment\_parameters) | Enrichment parameters. | <pre>object({<br/>    http_parameters = optional(object({<br/>      header_parameters       = optional(map(string))<br/>      path_parameter_values   = optional(list(string))<br/>      query_string_parameters = optional(map(string))<br/>    }))<br/>    input_template = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_log_configuration"></a> [log\_configuration](#input\_log\_configuration) | Log configuration for the pipe. | <pre>object({<br/>    cloudwatch_logs_log_destination = optional(object({<br/>      log_group_arn = string<br/>    }))<br/>    firehose_log_destination = optional(object({<br/>      delivery_stream_arn = string<br/>    }))<br/>    s3_log_destination = optional(object({<br/>      bucket_name   = string<br/>      bucket_owner  = string<br/>      output_format = optional(string)<br/>      prefix        = optional(string)<br/>    }))<br/>    include_execution_data = optional(set(string))<br/>    level                  = string<br/>  })</pre> | `null` | no |
| <a name="input_source_parameters"></a> [source\_parameters](#input\_source\_parameters) | Source parameters for the pipe. | `any` | `null` | no |
| <a name="input_target_parameters"></a> [target\_parameters](#input\_target\_parameters) | Target parameters for the pipe. | `any` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for the resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the pipe. |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the pipe. |
| <a name="output_name"></a> [name](#output\_name) | The name of the pipe. |
| <a name="output_desired_state"></a> [desired\_state](#output\_desired\_state) | The desired state of the pipe (RUNNING or STOPPED). |
| <a name="output_source"></a> [source](#output\_source) | The ARN of the source resource. |
| <a name="output_target"></a> [target](#output\_target) | The ARN of the target resource. |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | The ARN of the IAM role used by the pipe. |
<!-- END_TF_DOCS -->
