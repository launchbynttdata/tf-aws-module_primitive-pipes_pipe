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

output "id" {
  description = "The ID of the pipe."
  value       = module.pipe.id
}

output "arn" {
  description = "The ARN of the pipe."
  value       = module.pipe.arn
}

output "name" {
  description = "The name of the pipe."
  value       = module.pipe.name
}

output "description" {
  description = "The description of the pipe."
  value       = module.pipe.description
}

output "desired_state" {
  description = "The desired state of the pipe (RUNNING or STOPPED)."
  value       = module.pipe.desired_state
}

output "source" {
  description = "The ARN of the source resource."
  value       = module.pipe.source
}

output "target" {
  description = "The ARN of the target resource."
  value       = module.pipe.target
}

output "role_arn" {
  description = "The ARN of the IAM role used by the pipe."
  value       = module.pipe.role_arn
}

output "enrichment" {
  description = "The ARN of the enrichment resource, if configured."
  value       = module.pipe.enrichment
}

output "kms_key_identifier" {
  description = "The KMS key identifier used for pipe-level encryption."
  value       = module.pipe.kms_key_identifier
}

output "tags_all" {
  description = "Map of tags assigned to the resource, including those inherited from the provider."
  value       = module.pipe.tags_all
}
