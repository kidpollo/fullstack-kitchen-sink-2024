# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# This is the configuration for Terragrunt, a thin wrapper for Terraform that helps keep your code DRY and
# maintainable: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  source = "../../../../modules/todo-table-stream"
}

locals {
}

dependency "stream_lambda" {
  config_path = "../todo_python_lambda"
  mock_outputs = {
    lambda_function_arn = "arn:aws:lambda:us-east-1:123456789012:function:todo-stream-lambda"
    stream_lambda_role_name    = "stream-lambda-role"
  }
}

dependency "todo_dynamodb" {
  config_path = "../todo_ddb_table"
  mock_outputs = {
    table_arn = "arn:aws:dynamodb:us-east-1:123456789012:table/todo"
    stream_arn = "arn:aws:dynamodb:us-east-1:123456789012:table/todo/stream/2019-12-12T21:48:09.123"
  }
}

inputs = {
  stream_lambda_arn = dependency.stream_lambda.outputs.lambda_function_arn
  stream_lambda_role_name = dependency.stream_lambda.outputs.lambda_role_name
  table_arn = dependency.todo_dynamodb.outputs.table_arn
  todo_stream_arn = dependency.todo_dynamodb.outputs.stream_arn
}

