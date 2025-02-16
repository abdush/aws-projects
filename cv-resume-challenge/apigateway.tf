data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "visitor-counter-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
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