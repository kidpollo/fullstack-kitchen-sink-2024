# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# This is the configuration for Terragrunt, a thin wrapper for Terraform that helps keep your code DRY and
# maintainable: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  source = "../../../../modules/common-lambda"
}

locals {
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

dependency "todo_ts_package" {
  config_path =  "../todo_ts_package"
  mock_outputs = {
    package_filename = "todo-ts-lambda.zip"
    package_runtime = "nodejs20.x"
    package_handler = "index.handler"
    package_content_base64sha256 = "sha"
  }
}

dependency "todo_dynamodb" {
  config_path = "../todo_ddb_table"
  mock_outputs = {
    table_name = "todo-ddb-table"
  }
}


inputs = merge(dependency.todo_ts_package.outputs, {
  function_name = "todo-ts-lambda"
  aws_region = local.region_vars.locals.aws_region
  lambda_path = "${get_repo_root()}/ts-lambda-backend"
  env = local.env_vars.locals.environment
  lambda_env_vars = {
    TODOS_TABLE_NAME = dependency.todo_dynamodb.outputs.table_name
  }
})
