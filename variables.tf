// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

# -----------------------------------------------------------------------------
# Naming
# -----------------------------------------------------------------------------

variable "name" {
  description = "Name of the pipe. Must be unique within the account and region. Conflicts with name_prefix. Exactly one of name or name_prefix must be set."
  type        = string
  default     = null

  validation {
    condition     = var.name == null ? true : (length(var.name) >= 1 && length(var.name) <= 64 && can(regex("^[0-9A-Za-z_.-]+$", var.name)))
    error_message = "Name must be 1-64 characters and contain only alphanumerics, underscores, periods, and hyphens."
  }
}

variable "name_prefix" {
  description = "Creates a unique name beginning with the specified prefix. Conflicts with name. Exactly one of name or name_prefix must be set."
  type        = string
  default     = null

  validation {
    condition     = var.name_prefix == null ? true : (length(var.name_prefix) >= 1 && length(var.name_prefix) <= 64 - 26 && can(regex("^[0-9A-Za-z_.-]+$", var.name_prefix)))
    error_message = "Name prefix must be 1-38 characters (leaving room for unique suffix) and contain only alphanumerics, underscores, periods, and hyphens."
  }
}

# -----------------------------------------------------------------------------
# Required
# -----------------------------------------------------------------------------

variable "role_arn" {
  description = "ARN of the IAM role used by the pipe to invoke the source and target."
  type        = string

  validation {
    condition     = can(regex("^arn:", var.role_arn))
    error_message = "Role ARN must be a valid ARN."
  }
}

variable "source_arn" {
  description = "ARN or SMK URL of the source resource (e.g., SQS queue, DynamoDB stream, Kinesis stream)."
  type        = string

  validation {
    condition     = can(regex("^(arn:|smk://)", var.source_arn))
    error_message = "Source must be a valid ARN or SMK URL."
  }
}

variable "target_arn" {
  description = "ARN of the target resource (e.g., Lambda function, SQS queue, SNS topic)."
  type        = string

  validation {
    condition     = can(regex("^arn:", var.target_arn))
    error_message = "Target must be a valid ARN."
  }
}

# -----------------------------------------------------------------------------
# Optional - Basic
# -----------------------------------------------------------------------------

variable "description" {
  description = "Description of the pipe."
  type        = string
  default     = "Managed by Terraform"
}

variable "desired_state" {
  description = "Desired state of the pipe. Valid values: RUNNING, STOPPED."
  type        = string
  default     = "RUNNING"

  validation {
    condition     = contains(["RUNNING", "STOPPED"], var.desired_state)
    error_message = "Desired state must be RUNNING or STOPPED."
  }
}

variable "enrichment" {
  description = "ARN of an enrichment resource (e.g., Lambda, API Gateway)."
  type        = string
  default     = null

  validation {
    condition     = var.enrichment == null || can(regex("^arn:", var.enrichment))
    error_message = "Enrichment must be a valid ARN when set."
  }
}

variable "kms_key_identifier" {
  description = "ARN or alias of the KMS key used to encrypt pipe data."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Optional - Complex blocks (passed through to provider)
# -----------------------------------------------------------------------------

variable "enrichment_parameters" {
  description = <<-EOT
    Enrichment parameters for HTTP enrichment. Supports:
    - http_parameters: header_parameters, path_parameter_values, query_string_parameters
    - input_template: JSON template (0-8192 chars)
  EOT
  type = object({
    http_parameters = optional(object({
      header_parameters       = optional(map(string))
      path_parameter_values   = optional(list(string))
      query_string_parameters = optional(map(string))
    }))
    input_template = optional(string)
  })
  default = null

  validation {
    condition     = var.enrichment_parameters == null ? true : (try(var.enrichment_parameters.input_template, null) == null ? true : (length(var.enrichment_parameters.input_template) >= 0 && length(var.enrichment_parameters.input_template) <= 8192))
    error_message = "Input template must be 0-8192 characters."
  }
}

variable "log_configuration" {
  description = <<-EOT
    Log configuration for the pipe. Requires level. Supports:
    - cloudwatch_logs_log_destination: log_group_arn
    - firehose_log_destination: delivery_stream_arn
    - s3_log_destination: bucket_name, bucket_owner, output_format, prefix
    - include_execution_data: list of IncludeExecutionDataOption values
    - level: OFF, ERROR, INFO, TRACE (required)
  EOT
  type = object({
    cloudwatch_logs_log_destination = optional(object({
      log_group_arn = string
    }))
    firehose_log_destination = optional(object({
      delivery_stream_arn = string
    }))
    s3_log_destination = optional(object({
      bucket_name   = string
      bucket_owner  = string
      output_format = optional(string) # PlainText, Json
      prefix        = optional(string)
    }))
    include_execution_data = optional(list(string)) # INCLUDE, EXCLUDE
    level                  = string                 # OFF, ERROR, INFO, TRACE
  })
  default = null

  validation {
    condition     = var.log_configuration == null ? true : contains(["OFF", "ERROR", "INFO", "TRACE"], var.log_configuration.level)
    error_message = "Log configuration level must be one of: OFF, ERROR, INFO, TRACE."
  }
}

variable "source_parameters" {
  description = <<-EOT
    Source-specific parameters. Intentionally typed as `any` to mirror provider schema evolution without frequent breaking changes.
    Supports filter_criteria and one of:
    activemq_broker_parameters, dynamodb_stream_parameters, kinesis_stream_parameters,
    managed_streaming_kafka_parameters, rabbitmq_broker_parameters,
    self_managed_kafka_parameters, sqs_queue_parameters.
    See: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/pipes_pipe#source_parameters
  EOT
  type        = any
  default     = null
}

variable "target_parameters" {
  description = <<-EOT
    Target-specific parameters. Intentionally typed as `any` to mirror provider schema evolution without frequent breaking changes.
    Supports input_template and one of:
    batch_job_parameters, cloudwatch_logs_parameters, ecs_task_parameters,
    eventbridge_event_bus_parameters, http_parameters, kinesis_stream_parameters,
    lambda_function_parameters, redshift_data_parameters, sagemaker_pipeline_parameters,
    sqs_queue_parameters, step_function_state_machine_parameters.
    See: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/pipes_pipe#target_parameters
  EOT
  type        = any
  default     = null
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------

variable "tags" {
  description = "Map of tags to assign to the pipe."
  type        = map(string)
  default     = {}
}
