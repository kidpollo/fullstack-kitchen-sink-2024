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

dependency "py-package" {
  config_path = "../todo_python_package"
  mock_outputs = {
    package_filename = "todo-py-lambda.zip"
    package_runtime = "python3.12"
    package_handler = "index.handler"
    package_content_base64sha256 = "sha"
  }
}

inputs = merge(dependency.py-package.outputs, {
  function_name = "todo-python-lambda"
  aws_region = local.region_vars.locals.aws_region
  lambda_path = "${get_repo_root()}/python-lambda-backend"
  env = local.env_vars.locals.environment
})
