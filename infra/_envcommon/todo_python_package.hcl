# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# This is the configuration for Terragrunt, a thin wrapper for Terraform that helps keep your code DRY and
# maintainable: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  source = "../../../../modules/python-package"
}

inputs = {
  py_code_path = "${get_repo_root()}/python-lambda-backend"
}
