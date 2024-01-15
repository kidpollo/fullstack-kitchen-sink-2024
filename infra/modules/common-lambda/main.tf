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
  lambda_log_level = var.lambda_log_level
  function_name = var.function_name
  aws_region = var.aws_region
  env = var.env
  package_filename = var.package_filename
  package_runtime = var.package_runtime
  package_handler = var.package_handler
  package_content_base64sha256 = var.package_content_base64sha256
}

# Create an IAM execution role for the Lambda function.
resource "aws_iam_role" "execution_role" {
  # IAM Roles are "global" resources. Lambda functions aren't.
  # In order to deploy the Lambda function in multiple regions
  # within the same account, separate Roles must be created.
  # The same Role could be shared across different Lambda functions,
  # but it's just not convenient to do so in Terraform.
  name = "lambda-execution-role-${local.function_name}-${local.aws_region}-${local.env}"

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
  name = "lambda-log-writer-policy-${local.function_name}-${local.env}"
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
  function_name = "${local.function_name}-${local.env}"
  //description = "TODO"
  role = aws_iam_role.execution_role.arn
  filename = local.package_filename
  runtime = local.package_runtime
  handler = local.package_handler
  memory_size = 128
  timeout = 30
  source_code_hash = local.package_content_base64sha256

  environment {
    variables = {
      LOG_LEVEL = local.lambda_log_level
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
