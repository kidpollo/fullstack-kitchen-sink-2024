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
  lambda_src_path = "${var.lambda_path}"
  tmp_path = "${path.module}/.tmp"
  source_files = fileset(local.lambda_src_path, "**")
}

# Compute the source code hash, only taking into
# consideration the actual application code files
# and the dependencies list.
resource "random_uuid" "lambda_src_hash" {
  keepers = {
    for filename in setunion(
      [for f in fileset(local.lambda_src_path, "**/*.ts"): f if length(regexall("node_modules", f)) == 0],
      fileset(local.lambda_src_path, "package.json"),
    ):
    filename => filemd5("${local.lambda_src_path}/${filename}")
  }
}

# Build ts lambda package
# Thankfuly, the Bun script does this nicely for us.
resource "null_resource" "build_package" {
  provisioner "local-exec" {
    command = "cd ${local.lambda_src_path} && bun install && bun run build"

    environment = {
      tmp_path = local.tmp_path
      lambda_src_path = local.lambda_src_path
    }
  }

  # Only re-run this if the dependencies or their versions
  # have changed since the last deployment with Terraform
  triggers = {
    source_code_hash = random_uuid.lambda_src_hash.result
  }
}

# Get the created archive file from the bun build script
data "local_file" "lambda_source_package" {
  filename = "${local.lambda_src_path}/dist/bundle.zip"
  depends_on = [null_resource.build_package]
}

# Create an IAM execution role for the Lambda function.
resource "aws_iam_role" "execution_role" {
  # IAM Roles are "global" resources. Lambda functions aren't.
  # In order to deploy the Lambda function in multiple regions
  # within the same account, separate Roles must be created.
  # The same Role could be shared across different Lambda functions,
  # but it's just not convenient to do so in Terraform.
  name = "lambda-execution-role-${var.function_name}-${var.aws_region}-${var.env}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Attach a IAM policy to the execution role to allow
# the Lambda to stream logs to Cloudwatch Logs.
resource "aws_iam_role_policy" "log_writer" {
  name = "lambda-log-writer-policy-${var.function_name}-${var.env}"
  role = aws_iam_role.execution_role.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Deploy the Lambda function to AWS
resource "aws_lambda_function" "lambda_fn" {
  function_name = "${var.function_name}-${var.env}"
  //description = "TODO"
  role = aws_iam_role.execution_role.arn
  filename = data.local_file.lambda_source_package.filename
  runtime = "nodejs18.x"
  handler = "index.handler"
  memory_size = 128
  timeout = 30
  source_code_hash = data.local_file.lambda_source_package.content_base64sha256

  environment {
    variables = {
      LOG_LEVEL = var.lambda_log_level
    }
  }

  lifecycle {
    # Terraform will any ignore changes to the
    # environment variables after the first deploy.
    ignore_changes = [environment]
  }
}

# The Lambda function would create this Log Group automatically
# at runtime if provided with the correct IAM policy, but
# we explicitly create it to set an expiration date to the streams.
resource "aws_cloudwatch_log_group" "lambda_fn" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_fn.function_name}"
  retention_in_days = 30
}

output "lambda_function_arn" {
  value = aws_lambda_function.lambda_fn.arn
}
