# Terraform AWS Module - EventBridge Pipes Pipe

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Overview

This Terraform module creates and manages an [AWS EventBridge Pipes Pipe](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-pipes.html). EventBridge Pipes connect event sources (SQS, DynamoDB Streams, Kinesis, etc.) to targets (Lambda, SQS, SNS, etc.) with optional enrichment and filtering.

## Documentation

- [Terraform Registry - aws_pipes_pipe](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/pipes_pipe)
- [AWS EventBridge Pipes User Guide](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-pipes.html)

## Pre-Commit Hooks

The [.pre-commit-config.yaml](.pre-commit-config.yaml) defines hooks for Terraform, Go, and linting. The `detect-secrets-hook` prevents new secrets from being introduced. See [pre-commit](https://pre-commit.com/) for installation.

For commit message format, install the commit-msg hook:

```
pre-commit install --hook-type commit-msg
```

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

  description        = var.description
  desired_state      = var.desired_state
  enrichment         = var.enrichment
  kms_key_identifier = coalesce(var.kms_key_identifier, aws_kms_key.sqs.arn)

  enrichment_parameters = var.enrichment_parameters
  log_configuration     = var.log_configuration
  source_parameters     = var.source_parameters
  target_parameters     = var.target_parameters

  tags = var.tags
}
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

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_pipes_pipe.pipe](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/pipes_pipe) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name of the pipe. Must be unique within the account and region. Conflicts with name\_prefix. Exactly one of name or name\_prefix must be set. | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Creates a unique name beginning with the specified prefix. Conflicts with name. Exactly one of name or name\_prefix must be set. | `string` | `null` | no |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | ARN of the IAM role used by the pipe to invoke the source and target. | `string` | n/a | yes |
| <a name="input_source_arn"></a> [source\_arn](#input\_source\_arn) | ARN or SMK URL of the source resource (e.g., SQS queue, DynamoDB stream, Kinesis stream). | `string` | n/a | yes |
| <a name="input_target_arn"></a> [target\_arn](#input\_target\_arn) | ARN of the target resource (e.g., Lambda function, SQS queue, SNS topic). | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description of the pipe. | `string` | `"Managed by Terraform"` | no |
| <a name="input_desired_state"></a> [desired\_state](#input\_desired\_state) | Desired state of the pipe. Valid values: RUNNING, STOPPED. | `string` | `"RUNNING"` | no |
| <a name="input_enrichment"></a> [enrichment](#input\_enrichment) | ARN of an enrichment resource (e.g., Lambda, API Gateway). | `string` | `null` | no |
| <a name="input_kms_key_identifier"></a> [kms\_key\_identifier](#input\_kms\_key\_identifier) | ARN or alias of the KMS key used to encrypt pipe data. | `string` | `null` | no |
| <a name="input_enrichment_parameters"></a> [enrichment\_parameters](#input\_enrichment\_parameters) | Enrichment parameters for HTTP enrichment. Supports:<br/>- http\_parameters: header\_parameters, path\_parameter\_values, query\_string\_parameters<br/>- input\_template: JSON template (0-8192 chars) | <pre>object({<br/>    http_parameters = optional(object({<br/>      header_parameters       = optional(map(string))<br/>      path_parameter_values   = optional(list(string))<br/>      query_string_parameters = optional(map(string))<br/>    }))<br/>    input_template = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_log_configuration"></a> [log\_configuration](#input\_log\_configuration) | Log configuration for the pipe. Requires level. Supports:<br/>- cloudwatch\_logs\_log\_destination: log\_group\_arn<br/>- firehose\_log\_destination: delivery\_stream\_arn<br/>- s3\_log\_destination: bucket\_name, bucket\_owner, output\_format, prefix<br/>- include\_execution\_data: list of IncludeExecutionDataOption values<br/>- level: OFF, ERROR, INFO, TRACE (required) | <pre>object({<br/>    cloudwatch_logs_log_destination = optional(object({<br/>      log_group_arn = string<br/>    }))<br/>    firehose_log_destination = optional(object({<br/>      delivery_stream_arn = string<br/>    }))<br/>    s3_log_destination = optional(object({<br/>      bucket_name   = string<br/>      bucket_owner  = string<br/>      output_format = optional(string) # PlainText, Json<br/>      prefix        = optional(string)<br/>    }))<br/>    include_execution_data = optional(list(string)) # INCLUDE, EXCLUDE<br/>    level                  = string                 # OFF, ERROR, INFO, TRACE<br/>  })</pre> | `null` | no |
| <a name="input_source_parameters"></a> [source\_parameters](#input\_source\_parameters) | Source-specific parameters. Intentionally typed as `any` to mirror provider schema evolution without frequent breaking changes.<br/>Supports filter\_criteria and one of:<br/>activemq\_broker\_parameters, dynamodb\_stream\_parameters, kinesis\_stream\_parameters,<br/>managed\_streaming\_kafka\_parameters, rabbitmq\_broker\_parameters,<br/>self\_managed\_kafka\_parameters, sqs\_queue\_parameters.<br/>See: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/pipes_pipe#source_parameters | `any` | `null` | no |
| <a name="input_target_parameters"></a> [target\_parameters](#input\_target\_parameters) | Target-specific parameters. Intentionally typed as `any` to mirror provider schema evolution without frequent breaking changes.<br/>Supports input\_template and one of:<br/>batch\_job\_parameters, cloudwatch\_logs\_parameters, ecs\_task\_parameters,<br/>eventbridge\_event\_bus\_parameters, http\_parameters, kinesis\_stream\_parameters,<br/>lambda\_function\_parameters, redshift\_data\_parameters, sagemaker\_pipeline\_parameters,<br/>sqs\_queue\_parameters, step\_function\_state\_machine\_parameters.<br/>See: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/pipes_pipe#target_parameters | `any` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to the pipe. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the pipe (same as the name). |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the pipe. |
| <a name="output_name"></a> [name](#output\_name) | The name of the pipe. |
| <a name="output_description"></a> [description](#output\_description) | The description of the pipe. |
| <a name="output_desired_state"></a> [desired\_state](#output\_desired\_state) | The desired state of the pipe (RUNNING or STOPPED). |
| <a name="output_source"></a> [source](#output\_source) | The ARN of the source resource. |
| <a name="output_target"></a> [target](#output\_target) | The ARN of the target resource. |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | The ARN of the IAM role used by the pipe. |
| <a name="output_enrichment"></a> [enrichment](#output\_enrichment) | The ARN of the enrichment resource, if configured. |
| <a name="output_kms_key_identifier"></a> [kms\_key\_identifier](#output\_kms\_key\_identifier) | The KMS key identifier used for pipe-level encryption. |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | Map of tags assigned to the resource, including those inherited from the provider. |
<!-- END_TF_DOCS -->

## Example

See [examples/complete](examples/complete) for a full working example with SQS source and target.

## Functional Test Idempotency Exception

The `post_deploy_functional` and `post_deploy_functional_readonly` suites intentionally set `IS_TERRAFORM_IDEMPOTENT_APPLY = false` for the `complete` example.

This exception is currently required due to upstream behavior outside this module:

- The AWS provider has an open `aws_pipes_pipe` stability issue where nested dynamic blocks can produce repeated in-place changes across applies even when configuration is unchanged: [hashicorp/terraform-provider-aws#40007](https://github.com/hashicorp/terraform-provider-aws/issues/40007).
- AWS EventBridge Pipes creation/update behavior is asynchronous and eventually consistent for pipe polling/startup, which can introduce transient state timing differences during immediate re-apply windows in automation:
  - [Starting or stopping an Amazon EventBridge pipe](https://docs.aws.amazon.com/eventbridge/latest/userguide/pipes-start-stop.html)
  - [Amazon Kinesis stream as a source for EventBridge Pipes](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-pipes-kinesis.html)

## License

Apache 2.0 - See [LICENSE](LICENSE) for details.
