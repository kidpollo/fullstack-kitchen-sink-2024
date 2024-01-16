# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
#
# This is the configuration for Terragrunt, a thin wrapper for Terraform that
# helps keep your code DRY and maintainable:
# https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

# NOTE: With everything in a monorepo we use the capacity of targetting sepcific
# module versions per environment. If we had modules in a separate repo we
# could override the moodule version of for this environment like so:
# terraform {
#   source = "${include.envcommon.locals.base_source_url}?ref=v0.7.0"
# }

# ---------------------------------------------------------------------------------------------------------------------
# Include configurations that are common used across multiple environments.
# ---------------------------------------------------------------------------------------------------------------------

# Include the root `terragrunt.hcl` configuration. The root configuration
# contains settings that are common across all components and environments, such
# as how to configure remote state.
include "root" {
  path = find_in_parent_folders()
}

# Include the envcommon configuration for the component. The envcommon
# configuration contains settings that are common for the component across all
# environments.
include "todo_python_lambda" {
  path   = "${dirname(find_in_parent_folders())}/_envcommon/todo_python_lambda.hcl"
}

# ---------------------------------------------------------------------------------------------------------------------
# We don't need to override any of the common parameters for this environment,
# so we don't specify any inputs.
# ---------------------------------------------------------------------------------------------------------------------
# inputs = { override = "me" }
