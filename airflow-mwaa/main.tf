#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

# Generate an AWS provider block
provider "aws" {
  alias   = "airflow_mwaa"
  region  = var.aws_region
  profile = var.aws_profile
}

data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

locals {
  azs           = slice(data.aws_availability_zones.available.names, 0, 2)
  resource_name = var.environment_name_suffix == null ? format("%s-%s-%s", var.platform, var.name, var.environment) : format("%s-%s-%s-%s", var.platform, var.name, var.environment, var.environment_name_suffix)

  bucket_name = format("%s-%s-%s",
    var.aws_account_id,
    var.aws_region,
    local.resource_name
  )
  tags = merge(
    var.tags,
    {
      Created_By : "Terraform",
      Environment : var.environment,
      Resource_Name : local.resource_name,
      Platform : var.platform,
      Region : var.aws_region
    }
  )

  # This block is HORRIBLY ugly. It was the ONLY way to have conditional file-checks for the diff files for MWAA.
  startup_env_path    = var.mwaa_dir_env_path != "" && fileexists("${var.mwaa_dir_env_path}/startup.sh") ? "${var.mwaa_dir_env_path}/startup.sh" : ""
  startup_region_path = var.mwaa_dir_region_path != "" && fileexists("${var.mwaa_dir_region_path}/startup.sh") ? "${var.mwaa_dir_region_path}/startup.sh" : ""
  startup_app_path    = var.mwaa_dir_app_path != "" && fileexists("${var.mwaa_dir_app_path}/startup.sh") ? "${var.mwaa_dir_app_path}/startup.sh" : ""
  startup_local_path  = fileexists("mwaa/startup.sh") ? "mwaa/startup.sh" : ""
  startup_test_1      = local.startup_app_path != "" ? local.startup_app_path : local.startup_region_path
  startup_test_2      = local.startup_test_1 != "" ? local.startup_test_1 : local.startup_env_path
  startup_path        = local.startup_test_2 != "" ? local.startup_test_2 : local.startup_local_path

  requirements_env_path    = var.mwaa_dir_env_path != "" && fileexists("${var.mwaa_dir_env_path}/requirements.txt") ? "${var.mwaa_dir_env_path}/requirements.txt" : ""
  requirements_region_path = var.mwaa_dir_region_path != "" && fileexists("${var.mwaa_dir_region_path}/requirements.txt") ? "${var.mwaa_dir_region_path}/requirements.txt" : ""
  requirements_app_path    = var.mwaa_dir_app_path != "" && fileexists("${var.mwaa_dir_app_path}/requirements.txt") ? "${var.mwaa_dir_app_path}/requirements.txt" : ""
  requirements_local_path  = fileexists("mwaa/requirements.txt") ? "mwaa/requirements.txt" : ""
  requirements_test_1      = local.requirements_app_path != "" ? local.requirements_app_path : local.requirements_region_path
  requirements_test_2      = local.requirements_test_1 != "" ? local.requirements_test_1 : local.requirements_env_path
  requirements_path        = local.requirements_test_2 != "" ? local.requirements_test_2 : local.requirements_local_path

  #plugins_env_path    = var.mwaa_dir_env_path != "" && fileexists("${var.mwaa_dir_env_path}/plugins.zip") ? "${var.mwaa_dir_env_path}/plugins.zip" : ""
  #plugins_region_path = var.mwaa_dir_region_path != "" && fileexists("${var.mwaa_dir_region_path}/plugins.zip") ? "${var.mwaa_dir_region_path}/plugins.zip" : ""
  #plugins_app_path    = var.mwaa_dir_app_path != "" && fileexists("${var.mwaa_dir_app_path}/plugins.zip") ? "${var.mwaa_dir_app_path}/plugins.zip" : ""
  #plugins_local_path  = fileexists("mwaa/plugins.zip") ? "mwaa/plugins.zip" : ""
  #plugins_test_1      = local.plugins_app_path != "" ? local.plugins_app_path : local.plugins_region_path
  #plugins_test_2      = local.plugins_test_1 != "" ? local.plugins_test_1 : local.plugins_env_path
  #plugins_path        = local.plugins_test_2 != "" ? local.plugins_test_2 : local.plugins_local_path
  # End HORRIBLY ugly block!
}

module "bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = local.bucket_name
  acl    = var.bucket_acl
  tags   = local.tags

  control_object_ownership = var.bucket_object_ownership_flag
  object_ownership         = var.bucket_object_ownership

  #  versioning = {
  #    enabled = true
  #  }
}

# Upload DAGS
resource "aws_s3_object" "dags" {
  provider   = aws.airflow_mwaa
  for_each   = fileset("dags/", "**")
  bucket     = module.bucket.s3_bucket_id
  key        = "dags/${each.value}"
  source     = "dags/${each.value}"
  etag       = filemd5("dags/${each.value}")
  depends_on = [
    module.bucket
  ]
}

# Upload startup.sh script.
resource "aws_s3_object" "startup" {
  provider   = aws.airflow_mwaa
  bucket     = module.bucket.s3_bucket_id
  key        = "mwaa/startup.sh"
  source     = local.startup_path
  etag       = filemd5(local.startup_path)
  depends_on = [
    module.bucket
  ]
  count = local.startup_path != "" ? 1 : 0
}

# Upload requirements.txt script.
resource "aws_s3_object" "requirements" {
  provider   = aws.airflow_mwaa
  bucket     = module.bucket.s3_bucket_id
  key        = "mwaa/requirements.txt"
  source     = local.requirements_path
  etag       = filemd5(local.requirements_path)
  depends_on = [
    module.bucket
  ]
  count = local.requirements_path != "" ? 1 : 0
}

# Upload plugins.zip script.
#resource "aws_s3_object" "plugins" {
#  provider   = aws.airflow_mwaa
#  bucket     = module.bucket.s3_bucket_id
#  key        = "mwaa/plugins.zip"
#  source     = local.plugins_path
#  etag       = filemd5(local.plugins_path)
#  depends_on = [
#    module.bucket
#  ]
#  count = local.plugins_path != "" ? 1 : 0
#}

#-----------------------------------------------------------
# NOTE: MWAA Airflow environment takes minimum of 20 mins
#-----------------------------------------------------------
module "mwaa" {

  source = "aws-ia/mwaa/aws"

  name              = local.resource_name
  airflow_version   = var.mwaa_airflow_version
  #  kms_key           = module.kms.arn
  environment_class = var.environment_class
  create_s3_bucket  = false
  source_bucket_arn = module.bucket.s3_bucket_arn
  dag_s3_path       = "dags"
  iam_role_name     = local.resource_name
  #  execution_role_arn = ""  # Arn of existing permission role.

  ## If uploading requirements.txt or plugins, you can enable these via these options
  #plugins_s3_path        = "mwaa/plugins.zip"
  requirements_s3_path   = "mwaa/requirements.txt"
  startup_script_s3_path = "mwaa/startup.sh"

  logging_configuration = {
    dag_processing_logs = {
      enabled   = var.mwaa_logging_scheduler_processing_flag
      log_level = var.mwaa_logging_scheduler_processing_level
    }

    scheduler_logs = {
      enabled   = var.mwaa_logging_scheduler_task_flag
      log_level = var.mwaa_logging_scheduler_task_level
    }

    task_logs = {
      enabled   = var.mwaa_logging_scheduler_task_flag
      log_level = var.mwaa_logging_scheduler_task_level
    }

    webserver_logs = {
      enabled   = var.mwaa_logging_scheduler_webserver_flag
      log_level = var.mwaa_logging_scheduler_webserver_level
    }

    worker_logs = {
      enabled   = var.mwaa_logging_scheduler_worker_flag
      log_level = var.mwaa_logging_scheduler_worker_level
    }
  }

  airflow_configuration_options = {
    "core.load_default_connections" = "false"
    "core.load_examples"            = "false"
    "webserver.dag_default_view"    = "tree"
    "webserver.dag_orientation"     = "TB"
  }

  min_workers = var.min_workers
  max_workers = var.max_workers
  vpc_id      = try(var.vpc_id, module.vpc.vpc_id)

  private_subnet_ids    = try(var.private_subnet_ids, module.vpc.private_subnets)
  create_security_group = var.security_group_ids == [] ? true : false
  security_group_ids    = try(var.security_group_ids, module.vpc.default_security_group_id)

  webserver_access_mode = var.mwaa_webserver_access_mode
  # Choose the Private network option(PRIVATE_ONLY) if your Apache Airflow UI is only accessed within a corporate network, and you do not require access to public repositories for web server requirements installation
  source_cidr           = var.source_cidr # Add your IP address to access Airflow UI

  tags = local.tags

  depends_on = [
    module.bucket,
    module.vpc
  ]

}

#---------------------------------------------------------------
# Supporting Resources
#---------------------------------------------------------------
module "vpc" {

  count = var.vpc_id != null ? 0 : 1

  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.1"

  name = var.name
  cidr = var.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = local.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# GitHub deploy IAM Role
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_user" "github_user" {
  name = "${local.resource_name}-github-deploy"
  path = "/"
  tags = local.tags
}

data "aws_iam_policy_document" "github_policy_permissions" {
  statement {
    effect  = "Allow"
    actions = [
      "s3:*"
    ]
    resources = [
      module.bucket.s3_bucket_arn,
      "${module.bucket.s3_bucket_arn}/*"
    ]
  }
}

# Give the GitHub user s3 access.
resource "aws_iam_user_policy" "lb_ro" {
  name   = "mwaa-s3-access"
  user   = aws_iam_user.github_user.id
  policy = data.aws_iam_policy_document.github_policy_permissions.json
  depends_on = [
    aws_iam_user.github_user
  ]
}

# Give Airflow Glue Permissions.
resource "aws_iam_role_policy" "getgluejob" {
  name   = "GluePermissions"
  role   = module.mwaa.mwaa_role_name
  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "glue:GetJob",
          "glue:StartJobRun",
          "glue:GetJobRun"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "iam:GetRole"
      ],
      "Effect": "Allow",
      "Resource": "${module.mwaa.mwaa_role_arn}"
    }
  ]
}
EOT
}

# Custom Inline Policy, any JSON can be passed. Use {{MWAA_ROLE_ARN}} to denote the arn being used by MWAA.
resource "aws_iam_role_policy" "custom_inline_policy" {
  name = "CustomInlinePolicy"
  role = module.mwaa.mwaa_role_name

  policy = var.mwaa_custom_inline_policy
  count  = var.mwaa_custom_inline_policy != "" ? 1 : 0
}
