# Inspired by:
# https://github.com/ruzin/terraform_aws_lambda_python
# https://github.com/edonosotti/terraform-terragrunt-aws-lambda-tutorial
terraform {
  # Live modules pin exact Terraform version; generic modules let consumers pin the version.
  required_version = "= 1.6.6"

  # Live modules pin exact provider version; generic modules let consumers pin the version.
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

# Define a local variable for the ts package
locals {
  ts_code_path = "${var.ts_code_path}"
  tmp_path = "${path.module}/.tmp"
  source_files = fileset(local.ts_code_path, "**")
}

# Compute the source code hash, only taking into
# consideration the actual application code files
# and the dependencies list.
resource "random_uuid" "lambda_src_hash" {
  keepers = {
    for filename in setunion(
      [for f in fileset(local.ts_code_path, "**/*.ts"): f if length(regexall("node_modules", f)) == 0],
      fileset(local.ts_code_path, "package.json"),
    ):
    filename => filemd5("${local.ts_code_path}/${filename}")
  }
}

# Build ts lambda package
# Thankfuly, the Bun script also creates the zip for us
resource "null_resource" "build_package" {
  provisioner "local-exec" {
    command = "cd ${local.ts_code_path} && bun install && bun run build"

    environment = {
      tmp_path = local.tmp_path
      ts_code_path = local.ts_code_path
    }
  }

  # Only re-run this if the dependencies or their versions
  # have changed since the last deployment with Terraform
  triggers = {
    source_code_hash = random_uuid.lambda_src_hash.result
  }
}

# Get the package filename
data "local_file" "lambda_source_package" {
  filename = "${local.ts_code_path}/dist/bundle.zip"
  depends_on = [null_resource.build_package]
}

output "package_filename" {
  value = data.local_file.lambda_source_package.filename
}

output "package_runtime" {
  value = "nodejs20.x"
}

output "package_handler" {
  value = "index.handler"
}

output "package_content_base64sha256" {
  value = data.local_file.lambda_source_package.content_base64sha256
}


