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

# Define a local variable for the Lambda function
locals {
  lambda_src_path = "${var.py_code_path}"
  tmp_path = "${local.lambda_src_path}/../.tmp"
  source_files = fileset(local.lambda_src_path, "**")
}

# Compute the source code hash, only taking into
# consideration the actual application code files
# and the dependencies list.
resource "random_uuid" "lambda_src_hash" {
  keepers = {
    for filename in setunion(
      fileset(local.lambda_src_path, "*.py"),
      fileset(local.lambda_src_path, "requirements.txt"),
      fileset(local.lambda_src_path, "./**/*.py")
    ):
    filename => filemd5("${local.lambda_src_path}/${filename}")
  }
}

# Automatically install dependencies to be packaged
# with the Lambda function as required by AWS Lambda:
# https://docs.aws.amazon.com/lambda/latest/dg/python-package.html#python-package-dependencies
# Moves the lamda source code to a temp folder and installs the dependencies
resource "null_resource" "install_dependencies" {
  provisioner "local-exec" {
    command = "${path.module}/package.sh"

    environment = {
      package_path = local.tmp_path
      lambda_src_path = local.lambda_src_path
    }
  }

  # Only re-run this if the dependencies or their versions
  # have changed since the last deployment with Terraform
  triggers = {
    dependencies_versions = filemd5("${local.lambda_src_path}/requirements.txt")
    source_code_hash = random_uuid.lambda_src_hash.result
  }
}

# Create an archive form the Lambda source code,
# filtering out unneeded files.
data "archive_file" "lambda_source_package" {
  type        = "zip"
  source_dir  = local.tmp_path
  output_path = "${local.tmp_path}/${random_uuid.lambda_src_hash.result}.zip"

  excludes    = [
    ".venv",
    "__pycache__",
    "tests"
  ]

  # This is necessary, since archive_file is now a
  # `data` source and not a `resource` anymore.
  # Use `depends_on` to wait for the "install dependencies"
  # task to be completed.
  depends_on = [null_resource.install_dependencies]
}


output "package_filename" {
  value = data.archive_file.lambda_source_package.output_path
}

output "package_runtime" {
  value = "python3.12"
}

output "package_handler" {
  value = "lambda.handler"
}

output "package_content_base64sha256" {
  value = data.archive_file.lambda_source_package.output_base64sha256
}
