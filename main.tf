provider "aws" {
  region = "us-east-1"
}

resource "aws_apigatewayv2_api" "main" {
  name          = "ToddsAPI"
  description   = "API Gateway for public endpoints"
  protocol_type = "HTTP"

  cors_configuration {
    allow_headers = ["*"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }
}

resource "aws_apigatewayv2_stage" "default" {
  api_id = aws_apigatewayv2_api.main.id
  name   = "$default"
  auto_deploy = true
}
