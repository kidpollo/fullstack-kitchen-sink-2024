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
  table_arn  = var.table_arn
  stream_lambda_arn = var.stream_lambda_arn
  stream_lambda_role_name = var.stream_lambda_role_name
  todo_stream_arn = var.todo_stream_arn
}

resource "aws_lambda_event_source_mapping" "todo_stream_mapping" {
  event_source_arn  = local.todo_stream_arn
  function_name     = local.stream_lambda_arn
  starting_position = "LATEST"
  # filter the stream to only trigger todo events, meaning PK starts with "todo"
  filter_criteria {
    key = "PK"
    value = "todo"
  }
}

# Lambda permissions

resource "aws_iam_policy" "dynamoDBLambdaPolicy" {
  name = "DynamoDBStreamLambdaPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Action": [ "logs:*" ],
        "Effect": "Allow",
        "Resource": [ "arn:aws:logs:*:*:*" ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:BatchGetItem",
          "dynamodb:GetRecords",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:GetShardIterator",
          "dynamodb:DescribeStream",
          "dynamodb:ListStreams",
          "dynamodb:Query",
          "dynamodb:UpdateItem"
        ]
        Resource = [
          "${local.table_arn}",
          "${local.table_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dynamoDBLambdaPolicyAttachment" {
  role       = local.stream_lambda_role_name
  policy_arn = aws_iam_policy.dynamoDBLambdaPolicy.arn
}
