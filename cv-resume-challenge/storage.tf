resource "aws_dynamodb_table" "visitor_count" {
  name           = "VisitorCountTable"
  billing_mode   = "PAY_PER_REQUEST"  # Cost-efficient: Only pay for usage
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name        = "VisitorCounter"
    Environment = "dev"
  }
}
