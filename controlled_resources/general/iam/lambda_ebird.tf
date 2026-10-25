resource "aws_iam_role" "lambda_ebird_functions_general" {
  name        = "lambda-ebird-functions-general-role"
  description = "For lambda functions made related to ebird API data pulls"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_ebird_basic_execution" {
  role       = aws_iam_role.lambda_ebird_functions_general.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "ebird_extended" {
  name = "ebird-lambda-extended-policies"
  role = aws_iam_role.lambda_ebird_functions_general.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = "arn:aws:secretsmanager:us-east-2:${local.account_id}:secret:eBird-api-credentials-Hh9Q32"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "arn:aws:s3:::connors-misc-blob-for-blobs/ebird/*"
      }
    ]
  })
}

import {
  to = aws_iam_role.lambda_ebird_functions_general
  id = "lambda-ebird-functions-general-role"
}

import {
  to = aws_iam_role_policy_attachment.lambda_ebird_basic_execution
  id = "lambda-ebird-functions-general-role/arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

import {
  to = aws_iam_role_policy.ebird_extended
  id = "lambda-ebird-functions-general-role:ebird-lambda-extended-policies"
}
