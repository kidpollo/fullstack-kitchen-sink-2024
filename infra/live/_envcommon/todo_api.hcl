# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# This is the configuration for Terragrunt, a thin wrapper for Terraform that helps keep your code DRY and
# maintainable: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  source = "../../../../../modules/todo-api"
}

locals {
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

dependency "todo_lambda" {
  config_path = "../todo_ts_lambda"
  mock_outputs = {
    lambda_function_arn = "arn:aws:lambda:us-east-1:123456789012:function:todo-lambda"
    lambda_role_name    = "todo-lambda-role"
  }
}

dependency "todo_dynamodb" {
  config_path = "../todo_ddb_table"
  mock_outputs = {
    table_arn = "arn:aws:dynamodb:us-east-1:123456789012:table/todo"
  }
}

inputs = {
  aws_region = local.region_vars.locals.aws_region
  lambda_arn = dependency.todo_lambda.outputs.lambda_function_arn
  lambda_role_name = dependency.todo_lambda.outputs.lambda_role_name
  env        = local.env_vars.locals.environment
  table_arn  = dependency.todo_dynamodb.outputs.table_arn
}
