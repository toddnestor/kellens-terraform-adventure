resource "aws_sqs_queue" "main" {
  name = "todds-awesome-queue"
}

resource "aws_apigatewayv2_integration" "message" {
  api_id              = aws_apigatewayv2_api.main.id
  description         = "SQS example"
  integration_type    = "AWS_PROXY"
  integration_subtype = "SQS-SendMessage"
  credentials_arn     = aws_iam_role.apigateway.arn

  request_parameters = {
    "QueueUrl"    = aws_sqs_queue.main.url
    "MessageBody" = "$request.body"
  }
}

resource "aws_apigatewayv2_route" "message" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "POST /v1/full-send"
  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.main.id

  target = "integrations/${aws_apigatewayv2_integration.message.id}"
}

data "archive_file" "sqs_lambda" {
  type        = "zip"
  source_file = "sqs-lambda/index.mjs"
  output_path = "sqs_lambda_function_payload.zip"
}

resource "aws_lambda_function" "sqs_subscriber" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "sqs_lambda_function_payload.zip"
  function_name = "toddSqsSubscriber"
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

resource "aws_lambda_event_source_mapping" "main" {
  event_source_arn = aws_sqs_queue.main.arn
  function_name    = aws_lambda_function.sqs_subscriber.function_name

  depends_on = [aws_iam_role_policy_attachment.sqs_policy]
}