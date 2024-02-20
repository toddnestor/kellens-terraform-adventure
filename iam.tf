data "aws_iam_policy_document" "invocation_role_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["apigateway.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "apigateway" {
  name               = "todds_api_policy"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.invocation_role_assume_role_policy.json
}

data "aws_iam_policy_document" "sqs_policy" {
  statement {
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.main.arn]
  }
}

resource "aws_iam_role_policy" "sqs_policy" {
  policy = data.aws_iam_policy_document.sqs_policy.json
  role   = aws_iam_role.apigateway.id
}

resource "aws_iam_role_policy" "invocation_policy" {
  name = "default"
  role = aws_iam_role.invocation_role.id

  policy = data.aws_iam_policy_document.invocation.json
}

data "aws_iam_policy_document" "invocation" {
  statement {
    actions = ["lambda:InvokeFunction"]
    resources = [
      aws_lambda_function.authorizer.arn,
    ]
  }
}
