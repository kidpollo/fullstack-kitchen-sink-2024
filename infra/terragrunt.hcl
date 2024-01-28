# Based on : https://github.com/gruntwork-io/terragrunt-infrastructure-modules-example/tree/master

# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()

    # Load vars available to all configurations if needed
    # arguments = [
    #   "-var-file=${get_parent_terragrunt_dir()}/global.tfvars"
    # ]
  }

  extra_arguments "aws_profile" {
    commands = [
      "init",
      "apply",
      "refresh",
      "import",
      "plan",
      "taint",
      "untaint"
    ]

    env_vars = {
      AWS_PROFILE = "${local.aws_profile}"
    }
  }
}

locals {
  project_name = "todo-fullstack-kitchen-sink"

  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Automatically load provider-level variables
  provider_vars = read_terragrunt_config(find_in_parent_folders("provider.hcl"))

  # Extract the variables we need for easy access
  account_name = local.account_vars.locals.account_name
  aws_profile  = local.account_vars.locals.aws_profile
  account_id   = local.account_vars.locals.aws_account_id
  aws_region   = local.region_vars.locals.aws_region
  provider_overrides = local.provider_vars.locals.overrides
  provider_endpoints = local.provider_vars.locals.endpoints
  remote_state_config_overrides = local.provider_vars.locals.remote_state_config_overrides 
}

  # Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  =  <<-EOF
provider "aws" {
  region = "${local.aws_region}"

  %{for key, content in local.provider_overrides}
  ${key} = "${content}"%{endfor}

  endpoints {
    %{for key, content in local.provider_endpoints}
    ${key} = "${content}"%{endfor}
  }

  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = ["${local.account_id}"]
  profile = "${local.aws_profile}"
  default_tags {
    tags = {
      "Project" = "${local.project_name}"
      "Account" = "${local.account_name}"
      "Region"  = "${local.aws_region}"
    }
  }
}
EOF
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"
  config = merge({
    encrypt        = true
    bucket         = "${get_env("TG_BUCKET_PREFIX", local.project_name)}-state-${local.account_name}-${local.aws_region}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    dynamodb_table = "terraform-locks"
    profile        = local.aws_profile
  }, local.remote_state_config_overrides)
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.account_vars.locals,
  local.region_vars.locals,
  local.environment_vars.locals,
)
