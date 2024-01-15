resource "aws_dynamodb_table" "todos-table" {
  name           = "todo-${var.env}"
  billing_mode   = "PAY_PER_REQUEST"
  stream_enabled = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  hash_key  = "PK"
  range_key = "SK"
}

output "arn" {
  value = aws_dynamodb_table.ocho-master-table.arn
}

output "stream_arn" {
  value = aws_dynamodb_table.ocho-master-table.stream_arn
}
