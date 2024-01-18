variable "env" {
  description = "The environment to deploy the resources into."
}

variable "aws_region" {
  description = "The AWS region to deploy the resources into."
}

variable "lambda_arn" {
  description = "ARN of the lambda function"
}

variable "lambda_role_name" {
  description = "Name of the lambda role"
}

variable "table_arn" {
  description = "ARN of the DynamoDB table"
}
