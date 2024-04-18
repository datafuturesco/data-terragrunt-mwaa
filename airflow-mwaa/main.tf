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
  
  bucket_name   = format("%s-%s-%s",
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
}

module "bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = local.bucket_name
  acl    = "private"
  tags   = local.tags

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

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

# Upload plugins/requirements.txt
resource "aws_s3_object" "mwaa" {
  provider   = aws.airflow_mwaa
  for_each   = fileset("mwaa/", "*")
  bucket     = module.bucket.s3_bucket_id
  key        = each.value
  source     = "mwaa/${each.value}"
  etag       = filemd5("mwaa/${each.value}")
  depends_on = [
    module.bucket
  ]
}

#-----------------------------------------------------------
# NOTE: MWAA Airflow environment takes minimum of 20 mins
#-----------------------------------------------------------
module "mwaa" {

  source = "aws-ia/mwaa/aws"

  name              = local.resource_name
  airflow_version   = "2.6.3"
  #  kms_key           = module.kms.arn
  environment_class = var.environment_class
  create_s3_bucket  = false
  source_bucket_arn = module.bucket.s3_bucket_arn
  dag_s3_path       = "dags"
  iam_role_name     = local.resource_name
  #  execution_role_arn = ""  # Arn of existing permission role.

  ## If uploading requirements.txt or plugins, you can enable these via these options
  #  plugins_s3_path      = "plugins.zip"
  requirements_s3_path   = "requirements.txt"
  startup_script_s3_path = "startup.sh"

  logging_configuration = {
    dag_processing_logs = {
      enabled   = true
      log_level = "INFO"
    }

    scheduler_logs = {
      enabled   = true
      log_level = "INFO"
    }

    task_logs = {
      enabled   = true
      log_level = "INFO"
    }

    webserver_logs = {
      enabled   = true
      log_level = "INFO"
    }

    worker_logs = {
      enabled   = true
      log_level = "INFO"
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

  webserver_access_mode = "PRIVATE_ONLY"
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

resource "aws_iam_user_policy" "lb_ro" {
  name   = "mwaa-s3-access"
  user   = aws_iam_user.github_user.id
  policy = data.aws_iam_policy_document.github_policy_permissions.json
}

# Give Airflow Glue Permissions
resource "aws_iam_role_policy" "getgluejob" {
  name = "GluePermissions"
  role = module.mwaa.mwaa_role_name

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
      "Resource": "arn:aws:iam::966612968161:role/dwprod01-glue-job-role"
    }
  ]

}
EOT

}
