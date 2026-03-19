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

variable "resource_names_map" {
  description = "Map of resource names for the resource naming module. cloud_resource_type must be alphanumeric (letters and numbers)."
  type = map(object({
    name       = string
    max_length = number
  }))
  default = {
    enrichment_lambda = { name = "enrich1", max_length = 64 }
    iam_role          = { name = "iamrole1", max_length = 64 }
    source_queue      = { name = "sqsqueue1", max_length = 80 }
    target_queue      = { name = "sqsqueue2", max_length = 80 }
    pipe              = { name = "pipe1", max_length = 64 }
  }
}

variable "logical_product_family" {
  description = "Logical product family for resource naming."
  type        = string
}

variable "logical_product_service" {
  description = "Logical product service for resource naming."
  type        = string
}

variable "class_env" {
  description = "Class environment for resource naming."
  type        = string
}

variable "instance_env" {
  description = "Instance environment number for resource naming (0-999)."
  type        = number
}

variable "instance_resource" {
  description = "Instance resource number for resource naming (0-100)."
  type        = number
}

variable "name" {
  description = "Name of the pipe. Conflicts with name_prefix."
  type        = string
  default     = null
}

variable "name_prefix" {
  description = "Name prefix for the pipe. Conflicts with name."
  type        = string
  default     = null
}

variable "description" {
  description = "Description of the pipe."
  type        = string
  default     = "Managed by Terraform"
}

variable "desired_state" {
  description = "Desired state of the pipe (RUNNING or STOPPED)."
  type        = string
  default     = "RUNNING"
}

variable "kms_key_identifier" {
  description = "KMS key for pipe encryption."
  type        = string
  default     = null
}

variable "enrichment_parameters" {
  description = "Enrichment parameters."
  type = object({
    http_parameters = optional(object({
      header_parameters       = optional(map(string))
      path_parameter_values   = optional(list(string))
      query_string_parameters = optional(map(string))
    }))
    input_template = optional(string)
  })
  default = null
}

variable "log_configuration" {
  description = "Log configuration for the pipe."
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
      output_format = optional(string)
      prefix        = optional(string)
    }))
    include_execution_data = optional(list(string))
    level                  = string
  })
  default = null
}

variable "source_parameters" {
  description = "Source parameters for the pipe."
  type        = any
  default     = null
}

variable "target_parameters" {
  description = "Target parameters for the pipe."
  type        = any
  default     = null
}

variable "tags" {
  description = "Tags for the resources."
  type        = map(string)
  default     = {}
}
