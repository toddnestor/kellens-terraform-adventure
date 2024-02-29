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

resource "aws_iam_role_policy_attachment" "sqs_policy" {
  role       = aws_iam_role.iam_for_lambda.id
  policy_arn = aws_iam_policy.sqs_policy.arn
}

resource "aws_iam_policy" "sqs_policy" {
  name   = "todds_lambda_sqs_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.sqs_policy_doc.json
}

# sqs policies for the lambda
data "aws_iam_policy_document" "sqs_policy_doc" {
  statement {
    actions = [
      "sqs:DeleteMessage",
      "sqs:GetQueueUrl",
      "sqs:ChangeMessageVisibility",
      "sqs:SendMessageBatch",
      "sqs:ReceiveMessage",
      "sqs:SendMessage",
      "sqs:GetQueueAttributes",
      "sqs:ListQueueTags",
      "sqs:ListDeadLetterSourceQueues",
      "sqs:DeleteMessageBatch",
      "sqs:PurgeQueue",
      "sqs:DeleteQueue",
      "sqs:CreateQueue",
      "sqs:ChangeMessageVisibilityBatch",
      "sqs:SetQueueAttributes"
    ]
    resources = [
      aws_sqs_queue.main.arn
    ]
  }
}