# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# This is the configuration for Terragrunt, a thin wrapper for Terraform that helps keep your code DRY and
# maintainable: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# Include configurations that are common used across multiple environments.
# ---------------------------------------------------------------------------------------------------------------------

# Include the root `terragrunt.hcl` configuration. The root configuration contains settings that are common across all
# components and environments, such as how to configure remote state.
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../../modules/todo-api"
}

locals {
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

dependency "todo_lambda" {
  config_path = "../todo_ts_lambda" # relative path to the dependency's t
  mock_outputs = {
    lambda_function_arn = "arn:aws:lambda:us-east-1:123456789012:function:todo-lambda"
  }
}

inputs = {
  aws_region = local.region_vars.locals.aws_region
  lambda_arn = dependency.todo_lambda.outputs.lambda_function_arn
  env        = local.env_vars.locals.environment
}
