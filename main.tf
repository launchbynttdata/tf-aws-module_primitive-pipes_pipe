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

resource "aws_pipes_pipe" "pipe" {
  name               = var.name
  name_prefix        = var.name_prefix
  role_arn           = var.role_arn
  source             = var.source_arn
  target             = var.target_arn
  description        = var.description
  desired_state      = var.desired_state
  enrichment         = var.enrichment
  kms_key_identifier = var.kms_key_identifier
  tags               = var.tags

  dynamic "enrichment_parameters" {
    for_each = var.enrichment_parameters != null ? [var.enrichment_parameters] : []
    content {
      dynamic "http_parameters" {
        for_each = try(enrichment_parameters.value.http_parameters, null) != null ? [enrichment_parameters.value.http_parameters] : []
        content {
          header_parameters       = try(http_parameters.value.header_parameters, null)
          path_parameter_values   = try(http_parameters.value.path_parameter_values, null)
          query_string_parameters = try(http_parameters.value.query_string_parameters, null)
        }
      }
      input_template = try(enrichment_parameters.value.input_template, null)
    }
  }

  dynamic "log_configuration" {
    for_each = var.log_configuration != null ? [var.log_configuration] : []
    content {
      dynamic "cloudwatch_logs_log_destination" {
        for_each = try(log_configuration.value.cloudwatch_logs_log_destination, null) != null ? [log_configuration.value.cloudwatch_logs_log_destination] : []
        content {
          log_group_arn = cloudwatch_logs_log_destination.value.log_group_arn
        }
      }
      dynamic "firehose_log_destination" {
        for_each = try(log_configuration.value.firehose_log_destination, null) != null ? [log_configuration.value.firehose_log_destination] : []
        content {
          delivery_stream_arn = firehose_log_destination.value.delivery_stream_arn
        }
      }
      dynamic "s3_log_destination" {
        for_each = try(log_configuration.value.s3_log_destination, null) != null ? [log_configuration.value.s3_log_destination] : []
        content {
          bucket_name   = s3_log_destination.value.bucket_name
          bucket_owner  = s3_log_destination.value.bucket_owner
          output_format = try(s3_log_destination.value.output_format, null)
          prefix        = try(s3_log_destination.value.prefix, null)
        }
      }
      include_execution_data = try(log_configuration.value.include_execution_data, null)
      level                  = log_configuration.value.level
    }
  }

  dynamic "source_parameters" {
    for_each = var.source_parameters != null ? [var.source_parameters] : []
    content {
      dynamic "filter_criteria" {
        for_each = try(source_parameters.value.filter_criteria, null) != null ? [source_parameters.value.filter_criteria] : []
        content {
          dynamic "filter" {
            for_each = try(filter_criteria.value.filter, [])
            content {
              pattern = filter.value.pattern
            }
          }
        }
      }
      dynamic "activemq_broker_parameters" {
        for_each = try(source_parameters.value.activemq_broker_parameters, null) != null ? [source_parameters.value.activemq_broker_parameters] : []
        content {
          batch_size                         = try(activemq_broker_parameters.value.batch_size, null)
          maximum_batching_window_in_seconds = try(activemq_broker_parameters.value.maximum_batching_window_in_seconds, null)
          queue_name                         = activemq_broker_parameters.value.queue_name
          dynamic "credentials" {
            for_each = try(activemq_broker_parameters.value.credentials, null) != null ? [activemq_broker_parameters.value.credentials] : []
            content {
              basic_auth = credentials.value.basic_auth
            }
          }
        }
      }
      dynamic "dynamodb_stream_parameters" {
        for_each = try(source_parameters.value.dynamodb_stream_parameters, null) != null ? [source_parameters.value.dynamodb_stream_parameters] : []
        content {
          batch_size                         = try(dynamodb_stream_parameters.value.batch_size, null)
          maximum_batching_window_in_seconds = try(dynamodb_stream_parameters.value.maximum_batching_window_in_seconds, null)
          maximum_record_age_in_seconds      = try(dynamodb_stream_parameters.value.maximum_record_age_in_seconds, null)
          maximum_retry_attempts             = try(dynamodb_stream_parameters.value.maximum_retry_attempts, null)
          on_partial_batch_item_failure      = try(dynamodb_stream_parameters.value.on_partial_batch_item_failure, null)
          parallelization_factor             = try(dynamodb_stream_parameters.value.parallelization_factor, null)
          starting_position                  = dynamodb_stream_parameters.value.starting_position
          dynamic "dead_letter_config" {
            for_each = try(dynamodb_stream_parameters.value.dead_letter_config, null) != null ? [dynamodb_stream_parameters.value.dead_letter_config] : []
            content {
              arn = try(dead_letter_config.value.arn, null)
            }
          }
        }
      }
      dynamic "kinesis_stream_parameters" {
        for_each = try(source_parameters.value.kinesis_stream_parameters, null) != null ? [source_parameters.value.kinesis_stream_parameters] : []
        content {
          batch_size                         = try(kinesis_stream_parameters.value.batch_size, null)
          maximum_batching_window_in_seconds = try(kinesis_stream_parameters.value.maximum_batching_window_in_seconds, null)
          maximum_record_age_in_seconds      = try(kinesis_stream_parameters.value.maximum_record_age_in_seconds, null)
          maximum_retry_attempts             = try(kinesis_stream_parameters.value.maximum_retry_attempts, null)
          on_partial_batch_item_failure      = try(kinesis_stream_parameters.value.on_partial_batch_item_failure, null)
          parallelization_factor             = try(kinesis_stream_parameters.value.parallelization_factor, null)
          starting_position                  = kinesis_stream_parameters.value.starting_position
          starting_position_timestamp        = try(kinesis_stream_parameters.value.starting_position_timestamp, null)
          dynamic "dead_letter_config" {
            for_each = try(kinesis_stream_parameters.value.dead_letter_config, null) != null ? [kinesis_stream_parameters.value.dead_letter_config] : []
            content {
              arn = try(dead_letter_config.value.arn, null)
            }
          }
        }
      }
      dynamic "managed_streaming_kafka_parameters" {
        for_each = try(source_parameters.value.managed_streaming_kafka_parameters, null) != null ? [source_parameters.value.managed_streaming_kafka_parameters] : []
        content {
          batch_size                         = try(managed_streaming_kafka_parameters.value.batch_size, null)
          consumer_group_id                  = try(managed_streaming_kafka_parameters.value.consumer_group_id, null)
          maximum_batching_window_in_seconds = try(managed_streaming_kafka_parameters.value.maximum_batching_window_in_seconds, null)
          starting_position                  = try(managed_streaming_kafka_parameters.value.starting_position, null)
          topic_name                         = managed_streaming_kafka_parameters.value.topic_name
          dynamic "credentials" {
            for_each = try(managed_streaming_kafka_parameters.value.credentials, null) != null ? [managed_streaming_kafka_parameters.value.credentials] : []
            content {
              client_certificate_tls_auth = try(credentials.value.client_certificate_tls_auth, null)
              sasl_scram_512_auth         = try(credentials.value.sasl_scram_512_auth, null)
            }
          }
        }
      }
      dynamic "rabbitmq_broker_parameters" {
        for_each = try(source_parameters.value.rabbitmq_broker_parameters, null) != null ? [source_parameters.value.rabbitmq_broker_parameters] : []
        content {
          batch_size                         = try(rabbitmq_broker_parameters.value.batch_size, null)
          maximum_batching_window_in_seconds = try(rabbitmq_broker_parameters.value.maximum_batching_window_in_seconds, null)
          queue_name                         = rabbitmq_broker_parameters.value.queue_name
          virtual_host                       = try(rabbitmq_broker_parameters.value.virtual_host, null)
          dynamic "credentials" {
            for_each = try(rabbitmq_broker_parameters.value.credentials, null) != null ? [rabbitmq_broker_parameters.value.credentials] : []
            content {
              basic_auth = credentials.value.basic_auth
            }
          }
        }
      }
      dynamic "self_managed_kafka_parameters" {
        for_each = try(source_parameters.value.self_managed_kafka_parameters, null) != null ? [source_parameters.value.self_managed_kafka_parameters] : []
        content {
          batch_size                         = try(self_managed_kafka_parameters.value.batch_size, null)
          consumer_group_id                  = try(self_managed_kafka_parameters.value.consumer_group_id, null)
          maximum_batching_window_in_seconds = try(self_managed_kafka_parameters.value.maximum_batching_window_in_seconds, null)
          server_root_ca_certificate         = try(self_managed_kafka_parameters.value.server_root_ca_certificate, null)
          starting_position                  = try(self_managed_kafka_parameters.value.starting_position, null)
          topic_name                         = self_managed_kafka_parameters.value.topic_name
          dynamic "credentials" {
            for_each = try(self_managed_kafka_parameters.value.credentials, null) != null ? [self_managed_kafka_parameters.value.credentials] : []
            content {
              basic_auth                  = try(credentials.value.basic_auth, null)
              client_certificate_tls_auth = try(credentials.value.client_certificate_tls_auth, null)
              sasl_scram_256_auth         = try(credentials.value.sasl_scram_256_auth, null)
              sasl_scram_512_auth         = try(credentials.value.sasl_scram_512_auth, null)
            }
          }
          dynamic "vpc" {
            for_each = try(self_managed_kafka_parameters.value.vpc, null) != null ? [self_managed_kafka_parameters.value.vpc] : []
            content {
              security_groups = try(vpc.value.security_groups, null)
              subnets         = try(vpc.value.subnets, null)
            }
          }
        }
      }
      dynamic "sqs_queue_parameters" {
        for_each = try(source_parameters.value.sqs_queue_parameters, null) != null ? [source_parameters.value.sqs_queue_parameters] : []
        content {
          batch_size                         = try(sqs_queue_parameters.value.batch_size, null)
          maximum_batching_window_in_seconds = try(sqs_queue_parameters.value.maximum_batching_window_in_seconds, null)
        }
      }
    }
  }

  dynamic "target_parameters" {
    for_each = var.target_parameters != null ? [var.target_parameters] : []
    content {
      input_template = try(target_parameters.value.input_template, null)
      dynamic "batch_job_parameters" {
        for_each = try(target_parameters.value.batch_job_parameters, null) != null ? [target_parameters.value.batch_job_parameters] : []
        content {
          job_definition = batch_job_parameters.value.job_definition
          job_name       = batch_job_parameters.value.job_name
          parameters     = try(batch_job_parameters.value.parameters, null)
          dynamic "depends_on" {
            for_each = try(batch_job_parameters.value.depends_on, null) != null ? batch_job_parameters.value.depends_on : []
            content {
              job_id = try(depends_on.value.job_id, null)
              type   = try(depends_on.value.type, null)
            }
          }
          dynamic "array_properties" {
            for_each = try(batch_job_parameters.value.array_properties, null) != null ? [batch_job_parameters.value.array_properties] : []
            content {
              size = try(array_properties.value.size, null)
            }
          }
          dynamic "container_overrides" {
            for_each = try(batch_job_parameters.value.container_overrides, null) != null ? [batch_job_parameters.value.container_overrides] : []
            content {
              command       = try(container_overrides.value.command, null)
              instance_type = try(container_overrides.value.instance_type, null)
              dynamic "environment" {
                for_each = try(container_overrides.value.environment, null) != null ? container_overrides.value.environment : []
                content {
                  name  = try(environment.value.name, null)
                  value = try(environment.value.value, null)
                }
              }
              dynamic "resource_requirement" {
                for_each = try(container_overrides.value.resource_requirement, null) != null ? container_overrides.value.resource_requirement : []
                content {
                  type  = resource_requirement.value.type
                  value = resource_requirement.value.value
                }
              }
            }
          }
          dynamic "retry_strategy" {
            for_each = try(batch_job_parameters.value.retry_strategy, null) != null ? [batch_job_parameters.value.retry_strategy] : []
            content {
              attempts = try(retry_strategy.value.attempts, null)
            }
          }
        }
      }
      dynamic "cloudwatch_logs_parameters" {
        for_each = try(target_parameters.value.cloudwatch_logs_parameters, null) != null ? [target_parameters.value.cloudwatch_logs_parameters] : []
        content {
          log_stream_name = try(cloudwatch_logs_parameters.value.log_stream_name, null)
          timestamp       = try(cloudwatch_logs_parameters.value.timestamp, null)
        }
      }
      dynamic "ecs_task_parameters" {
        for_each = try(target_parameters.value.ecs_task_parameters, null) != null ? [target_parameters.value.ecs_task_parameters] : []
        content {
          enable_ecs_managed_tags = try(ecs_task_parameters.value.enable_ecs_managed_tags, null)
          enable_execute_command  = try(ecs_task_parameters.value.enable_execute_command, null)
          group                   = try(ecs_task_parameters.value.group, null)
          launch_type             = try(ecs_task_parameters.value.launch_type, null)
          platform_version        = try(ecs_task_parameters.value.platform_version, null)
          propagate_tags          = try(ecs_task_parameters.value.propagate_tags, null)
          reference_id            = try(ecs_task_parameters.value.reference_id, null)
          tags                    = try(ecs_task_parameters.value.tags, null)
          task_count              = try(ecs_task_parameters.value.task_count, null)
          task_definition_arn     = ecs_task_parameters.value.task_definition_arn
          dynamic "capacity_provider_strategy" {
            for_each = try(ecs_task_parameters.value.capacity_provider_strategy, null) != null ? ecs_task_parameters.value.capacity_provider_strategy : []
            content {
              base              = try(capacity_provider_strategy.value.base, null)
              capacity_provider = capacity_provider_strategy.value.capacity_provider
              weight            = try(capacity_provider_strategy.value.weight, null)
            }
          }
          dynamic "placement_constraint" {
            for_each = try(ecs_task_parameters.value.placement_constraint, null) != null ? ecs_task_parameters.value.placement_constraint : []
            content {
              expression = try(placement_constraint.value.expression, null)
              type       = try(placement_constraint.value.type, null)
            }
          }
          dynamic "placement_strategy" {
            for_each = try(ecs_task_parameters.value.placement_strategy, null) != null ? ecs_task_parameters.value.placement_strategy : []
            content {
              field = try(placement_strategy.value.field, null)
              type  = try(placement_strategy.value.type, null)
            }
          }
          dynamic "network_configuration" {
            for_each = try(ecs_task_parameters.value.network_configuration, null) != null ? [ecs_task_parameters.value.network_configuration] : []
            content {
              dynamic "aws_vpc_configuration" {
                for_each = try(network_configuration.value.aws_vpc_configuration, null) != null ? [network_configuration.value.aws_vpc_configuration] : []
                content {
                  assign_public_ip = try(aws_vpc_configuration.value.assign_public_ip, null)
                  security_groups  = try(aws_vpc_configuration.value.security_groups, null)
                  subnets          = try(aws_vpc_configuration.value.subnets, null)
                }
              }
            }
          }
          dynamic "overrides" {
            for_each = try(ecs_task_parameters.value.overrides, null) != null ? [ecs_task_parameters.value.overrides] : []
            content {
              cpu                = try(overrides.value.cpu, null)
              memory             = try(overrides.value.memory, null)
              task_role_arn      = try(overrides.value.task_role_arn, null)
              execution_role_arn = try(overrides.value.execution_role_arn, null)
              dynamic "ephemeral_storage" {
                for_each = try(overrides.value.ephemeral_storage, null) != null ? [overrides.value.ephemeral_storage] : []
                content {
                  size_in_gib = ephemeral_storage.value.size_in_gib
                }
              }
              dynamic "container_override" {
                for_each = try(overrides.value.container_override, [])
                content {
                  command = try(container_override.value.command, null)
                  cpu     = try(container_override.value.cpu, null)
                  memory  = try(container_override.value.memory, null)
                  name    = try(container_override.value.name, null)
                  dynamic "environment" {
                    for_each = try(container_override.value.environment, null) != null ? container_override.value.environment : []
                    content {
                      name  = try(environment.value.name, null)
                      value = try(environment.value.value, null)
                    }
                  }
                  dynamic "resource_requirement" {
                    for_each = try(container_override.value.resource_requirement, null) != null ? container_override.value.resource_requirement : []
                    content {
                      type  = resource_requirement.value.type
                      value = resource_requirement.value.value
                    }
                  }
                }
              }
            }
          }
        }
      }
      dynamic "eventbridge_event_bus_parameters" {
        for_each = try(target_parameters.value.eventbridge_event_bus_parameters, null) != null ? [target_parameters.value.eventbridge_event_bus_parameters] : []
        content {
          detail_type = try(eventbridge_event_bus_parameters.value.detail_type, null)
          endpoint_id = try(eventbridge_event_bus_parameters.value.endpoint_id, null)
          resources   = try(eventbridge_event_bus_parameters.value.resources, null)
          source      = try(eventbridge_event_bus_parameters.value.source, null)
          time        = try(eventbridge_event_bus_parameters.value.time, null)
        }
      }
      dynamic "http_parameters" {
        for_each = try(target_parameters.value.http_parameters, null) != null ? [target_parameters.value.http_parameters] : []
        content {
          header_parameters       = try(http_parameters.value.header_parameters, null)
          path_parameter_values   = try(http_parameters.value.path_parameter_values, null)
          query_string_parameters = try(http_parameters.value.query_string_parameters, null)
        }
      }
      dynamic "kinesis_stream_parameters" {
        for_each = try(target_parameters.value.kinesis_stream_parameters, null) != null ? [target_parameters.value.kinesis_stream_parameters] : []
        content {
          partition_key = kinesis_stream_parameters.value.partition_key
        }
      }
      dynamic "lambda_function_parameters" {
        for_each = try(target_parameters.value.lambda_function_parameters, null) != null ? [target_parameters.value.lambda_function_parameters] : []
        content {
          invocation_type = try(lambda_function_parameters.value.invocation_type, null)
        }
      }
      dynamic "redshift_data_parameters" {
        for_each = try(target_parameters.value.redshift_data_parameters, null) != null ? [target_parameters.value.redshift_data_parameters] : []
        content {
          database           = try(redshift_data_parameters.value.database, null)
          db_user            = try(redshift_data_parameters.value.db_user, null)
          secret_manager_arn = try(redshift_data_parameters.value.secret_manager_arn, null)
          sqls               = try(redshift_data_parameters.value.sqls, null)
          statement_name     = try(redshift_data_parameters.value.statement_name, null)
          with_event         = try(redshift_data_parameters.value.with_event, null)
        }
      }
      dynamic "sagemaker_pipeline_parameters" {
        for_each = try(target_parameters.value.sagemaker_pipeline_parameters, null) != null ? [target_parameters.value.sagemaker_pipeline_parameters] : []
        content {
          dynamic "pipeline_parameter" {
            for_each = try(sagemaker_pipeline_parameters.value.pipeline_parameter, null) != null ? sagemaker_pipeline_parameters.value.pipeline_parameter : []
            content {
              name  = try(pipeline_parameter.value.name, null)
              value = try(pipeline_parameter.value.value, null)
            }
          }
        }
      }
      dynamic "sqs_queue_parameters" {
        for_each = try(target_parameters.value.sqs_queue_parameters, null) != null ? [target_parameters.value.sqs_queue_parameters] : []
        content {
          message_deduplication_id = try(sqs_queue_parameters.value.message_deduplication_id, null)
          message_group_id         = try(sqs_queue_parameters.value.message_group_id, null)
        }
      }
      dynamic "step_function_state_machine_parameters" {
        for_each = try(target_parameters.value.step_function_state_machine_parameters, null) != null ? [target_parameters.value.step_function_state_machine_parameters] : []
        content {
          invocation_type = try(step_function_state_machine_parameters.value.invocation_type, null)
        }
      }
    }
  }

  lifecycle {
    precondition {
      condition     = (var.name == null) != (var.name_prefix == null)
      error_message = "Exactly one of name or name_prefix must be set."
    }
  }
}
