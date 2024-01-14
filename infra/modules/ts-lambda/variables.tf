variable "env" {
  description = "The environment to deploy the resources into."
}

variable "function_name" {
  description = "The name of the Lambda function."
}

variable "aws_region" {
  description = "The AWS region to deploy the resources into."
}

variable "lambda_log_level" {
  description = "Log level for the Lambda Python runtime."
  default = "DEBUG"
}

variable "lambda_path" {
  description = "path to the lambda code"
}
