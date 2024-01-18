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

variable "package_filename" {
  description = "The filename of the Lambda package."
}

variable "package_runtime" {
  description = "The runtime of the Lambda package."
}

variable "package_handler" {
  description = "The handler of the Lambda package."
}

variable "package_content_base64sha256" {
  description = "The base64 encoded sha256 hash of the Lambda package."
}

variable "lambda_env_vars" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}
