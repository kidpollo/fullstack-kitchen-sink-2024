# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

terraform {
  required_version = "1.6.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.32.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
  }
}

provider "aws" {
  region = "us-west-2" # eg. us-east-1
  profile = "nonprod"
}

module "dev_todo_app_service" {
  source = "../modules/ts-lambda"
  env = "dev"
  function_name = "dev-todo-app-service"
  aws_region = "us-west-2"
  lambda_log_level = "DEBUG"
  lambda_path = "${abspath(path.root)}/../../ts-lambda-backend"
}

# module "dev_api_gateway" {
#   source = "../modules/todo-api"
#   env = "dev"
#   aws_region = "us-west-2"
#   lambda_arn = module.dev_todo_app_service.lambda_function_arn
# }
