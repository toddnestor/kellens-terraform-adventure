resource "aws_apigatewayv2_integration" "lambda" {
  api_id              = aws_apigatewayv2_api.main.id
  integration_type = "AWS_PROXY"

  connection_type           = "INTERNET"
  description               = "Lambda example"
  integration_method        = "POST"
  integration_uri           = aws_lambda_function.endpoint.invoke_arn
  passthrough_behavior      = "WHEN_NO_MATCH"
}

resource "aws_apigatewayv2_route" "lambda" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "GET /v1/frfrfrfr"
  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.main.id

  target = "integrations/${aws_apigatewayv2_integration.message.id}"
}

data "archive_file" "endpoint_lambda" {
  type        = "zip"
  source_file = "endpoint-lambda/index.mjs"
  output_path = "endpoint_lambda_function_payload.zip"
}

resource "aws_lambda_function" "endpoint" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "endpoint_lambda_function_payload.zip"
  function_name = "toddEndpoint"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.handler"

  source_code_hash = data.archive_file.sqs_lambda.output_base64sha256

  runtime = "nodejs20.x"

  environment {
    variables = {
      foo = "bar"
    }
  }
}
