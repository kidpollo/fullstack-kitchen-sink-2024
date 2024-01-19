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

locals {
  lambda_arn = var.lambda_arn
  lambda_role_name = var.lambda_role_name
  table_arn  = var.table_arn
}

# API Gateway Logs
resource "aws_cloudwatch_log_group" "todo_service_logs" {
  name              = "/aws/api_gw/todo-app-service-${var.env}"
}

module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name          = "todo-app-service-${var.env}"
  description   = "TODO APP API"
  protocol_type = "HTTP"

  create_api_domain_name           = false
  create_default_stage_api_mapping = false

  integrations = {
    "GET /todo" = {
      lambda_arn             = local.lambda_arn
      payload_format_version = "2.0"
    }

    "POST /todo" = {
      lambda_arn             = local.lambda_arn
      payload_format_version = "2.0"
    }

    "PUT /todo/{id}" = {
      lambda_arn             = local.lambda_arn
      payload_format_version = "2.0"
    }

    "DELETE /todo/{id}" = {
      lambda_arn             = local.lambda_arn
      payload_format_version = "2.0"
    }
  }

  default_stage_access_log_destination_arn = aws_cloudwatch_log_group.todo_service_logs.arn
  default_stage_access_log_format = jsonencode({
    requestId               = "$context.requestId"
    sourceIp                = "$context.identity.sourceIp"
    requestTime             = "$context.requestTime"
    protocol                = "$context.protocol"
    httpMethod              = "$context.httpMethod"
    resourcePath            = "$context.resourcePath"
    routeKey                = "$context.routeKey"
    status                  = "$context.status"
    responseLength          = "$context.responseLength"
    integrationErrorMessage = "$context.integrationErrorMessage"
  })
}

# Lambda permissions

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = local.lambda_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gateway.apigatewayv2_api_execution_arn}/*"
}

resource "aws_iam_policy" "dynamoDBLambdaPolicy" {
  name = "DynamoDBLambdaPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:UpdateItem"
        ]
        Resource = [
          local.table_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dynamoDBLambdaPolicyAttachment" {
  role       = local.lambda_role_name
  policy_arn = aws_iam_policy.dynamoDBLambdaPolicy.arn
}
