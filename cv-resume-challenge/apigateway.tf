resource "aws_iam_role" "lambda_exec_role" {
  name = "visitor-counter-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "dynamodb_access" {
  name = "DynamoDBAccessPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:GetItem",
        "dynamodb:UpdateItem",
        "dynamodb:PutItem"
      ]
      Resource = aws_dynamodb_table.visitor_count.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.dynamodb_access.arn
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/api/lambda.py"
  output_path = "${path.module}/api/lambda_function_payload.zip"
}

resource "aws_lambda_function" "visitor_lambda" {
  filename      = data.archive_file.lambda.output_path
  function_name = "VisitorCounter"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda.lambda_handler"
  runtime       = "python3.9"

  source_code_hash = data.archive_file.lambda.output_base64sha256
}

# API Gateway
resource "aws_apigatewayv2_api" "visitor_api" {
  name          = "VisitorAPI"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["https://resume.ahussein.pro"]  # OR use ["*"] for testing
    allow_methods = ["GET"]
    allow_headers = ["*"]
  }
}

resource "aws_apigatewayv2_stage" "visitor_default" {
  api_id      = aws_apigatewayv2_api.visitor_api.id
  name        = "dev"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.visitor_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.visitor_lambda.invoke_arn
}

resource "aws_apigatewayv2_route" "visitor_route" {
  api_id    = aws_apigatewayv2_api.visitor_api.id
  route_key = "GET /visitor-count"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.visitor_api.execution_arn}/*/*"
}
