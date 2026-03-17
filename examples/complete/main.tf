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

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "resource_names" {
  source  = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version = "~> 2.0"

  for_each = var.resource_names_map

  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
  class_env               = var.class_env
  instance_env            = var.instance_env
  instance_resource       = var.instance_resource
  cloud_resource_type     = each.value.name
  maximum_length          = each.value.max_length
  region                  = join("", split("-", data.aws_region.current.name))
}

resource "aws_kms_key" "sqs" {
  description             = "KMS key for SQS queue encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow SQS to use the key"
        Effect = "Allow"
        Principal = {
          Service = "sqs.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
      {
        Sid    = "Allow EventBridge Pipes to use the key"
        Effect = "Allow"
        Principal = {
          Service = "pipes.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

resource "random_string" "kms_alias_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_kms_alias" "sqs" {
  name          = "alias/example-pipes-sqs-enc-${random_string.kms_alias_suffix.result}"
  target_key_id = aws_kms_key.sqs.key_id
}

resource "aws_iam_role" "pipe" {
  name = module.resource_names["iam_role"].standard

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "pipes.amazonaws.com"
      }
      Condition = {
        StringEquals = {
          "aws:SourceAccount" = data.aws_caller_identity.current.account_id
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "source" {
  role = aws_iam_role.pipe.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ReceiveMessage"
        ]
        Resource = [aws_sqs_queue.source.arn]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = [aws_kms_key.sqs.arn]
      }
    ]
  })
}

resource "aws_iam_role_policy" "target" {
  role = aws_iam_role.pipe.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage"
        ]
        Resource = [aws_sqs_queue.target.arn]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = [aws_kms_key.sqs.arn]
      }
    ]
  })
}

resource "aws_sqs_queue" "source" {
  name                              = module.resource_names["source_queue"].standard
  kms_master_key_id                 = aws_kms_key.sqs.arn
  kms_data_key_reuse_period_seconds = 300
  tags                              = var.tags
}

resource "aws_sqs_queue" "target" {
  name                              = module.resource_names["target_queue"].standard
  kms_master_key_id                 = aws_kms_key.sqs.arn
  kms_data_key_reuse_period_seconds = 300
  tags                              = var.tags
}

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
