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
    "MessageBody" = "$request.body.message"
  }
}

resource "aws_apigatewayv2_route" "message" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "POST /v1/full-send"

  target = "integrations/${aws_apigatewayv2_integration.message.id}"
}
