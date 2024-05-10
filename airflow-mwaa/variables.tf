variable "name" {
  description = "Name of MWAA Environment"
  default     = "airflow-mwaa"
  type        = string
}
variable "environment" {
  description = "Environment name."
  type        = string
  default     = null
}
variable "platform" {
  description = "Platform name."
  type        = string
  default     = null
}
variable "aws_region" {
  description = "AWS region."
  type        = string
}
variable "kms_key_arn" {
  description = "KMS CMK ARN to use by MWAA for data encryption. MUST reference the same KMS key as used by S3 bucket specified by source_bucket_arn, if the bucket uses KMS. If not specified, the default AWS owned key for MWAA will be used for backward compatibility with version 1.0.1 of this module."
  type        = string
  default     = null
}
variable "object_ownership" {
  description = "Default object ownership."
  type        = string
  default     = "BucketOwnerPreferred"
}
variable "aws_s3_bucket_acl" {
  description = "ACL of the bucket."
  type        = string
  default     = "private"
}
variable "aws_profile" {
  description = "AWS profile to use."
  type        = string
}
variable "aws_account_id" {
  description = "AWS account id to use."
  type        = string
}
variable "bucket_name_prefix" {
  description = "AWS bucket name prefix."
  type        = string
}
variable "tags" {
  description = "Default tags"
  default     = {}
  type        = map(string)
}

variable "vpc_cidr" {
  description = "VPC CIDR for MWAA"
  type        = string
  default     = "10.1.0.0/16"
}
variable "source_cidr" {
  type    = list(string)
  default = ["10.1.0.0/16"]
}

variable "vpc_id" {
  description = "VPC ID to use MWAA"
  type        = string
  default     = null
}

variable "security_group_ids" {
  description = "VPC security groups MWAA"
  type        = list(string)
  default     = []
}

variable "private_subnet_ids" {
  type    = list
  default = []
}

variable "min_workers" {
  type    = number
  default = 1
}
variable "max_workers" {
  type    = number
  default = 2
}
variable "environment_name_suffix" {
  type    = string
  default = null
}
variable "environment_class" {
  type    = string
  default = "mw1.small"
}
variable "mwaa_dir_env_path" {
  type    = string
  default = ""
}
variable "mwaa_dir_region_path" {
  type    = string
  default = ""
}
variable "mwaa_dir_app_path" {
  type    = string
  default = ""
}

variable "bucket_acl" {
  type    = string
  default = "private"
}

variable "bucket_object_ownership_flag" {
  type    = bool
  default = true
}

variable "bucket_object_ownership" {
  type    = string
  default = "ObjectWriter"
}

variable "mwaa_airflow_version" {
  type    = string
  default = "2.8.1"
}

variable "mwaa_create_s3_bucket" {
  type    = bool
  default = false
}

variable "mwaa_logging_dag_processing_flag" {
  type    = bool
  default = true
}
variable "mwaa_logging_dag_processing_level" {
  type    = string
  default = "INFO"
}
variable "mwaa_logging_scheduler_processing_flag" {
  type    = bool
  default = true
}
variable "mwaa_logging_scheduler_processing_level" {
  type    = string
  default = "INFO"
}
variable "mwaa_logging_scheduler_task_flag" {
  type    = bool
  default = true
}
variable "mwaa_logging_scheduler_task_level" {
  type    = string
  default = "INFO"
}
variable "mwaa_logging_scheduler_webserver_flag" {
  type    = bool
  default = true
}
variable "mwaa_logging_scheduler_webserver_level" {
  type    = string
  default = "INFO"
}
variable "mwaa_logging_scheduler_worker_flag" {
  type    = bool
  default = true
}
variable "mwaa_logging_scheduler_worker_level" {
  type    = string
  default = "INFO"
}

variable "mwaa_webserver_access_mode" {
  type    = string
  default = "PUBLIC_ONLY"
}

variable "mwaa_custom_inline_policy" {
  type        = string
  default     = ""
  description = "Pass any document using the <<-EOF method."
}
