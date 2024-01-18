resource "aws_dynamodb_table" "pk-sk-ddb-table" {
  name           = "${var.base_table_name}-${var.env}"
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

  # TODO: add functioanlity to add more indexes
}

output "table_arn" {
  value = aws_dynamodb_table.pk-sk-ddb-table.arn
}

output "stream_arn" {
  value = aws_dynamodb_table.pk-sk-ddb-table.stream_arn
}

output "table_name" {
  value = aws_dynamodb_table.pk-sk-ddb-table.name
}
