resource "aws_iam_role" "lambda_zeta_ball_api_to_sf" {
  name = "lambda-zeta-ball-api-to-sf-role-065dfwgs"
  path = "/service-role/"

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

# Despite the "BasicExecutionRole" name, this policy was expanded to include
# SecretsManager and S3 permissions needed by the Zeta Ball pipeline.
resource "aws_iam_policy" "lambda_basic_execution_zeta_ball" {
  name = "AWSLambdaBasicExecutionRole-3d5f6f34-bf79-4f2d-b275-020911225699"
  path = "/service-role/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "logs:CreateLogGroup"
        Resource = "arn:aws:logs:us-east-2:${local.account_id}:*"
      },
      {
        Effect = "Allow"
        Action = ["logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = [
          "arn:aws:logs:us-east-2:${local.account_id}:log-group:/aws/lambda/lambda-zeta-ball-api-to-sf:*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = "arn:aws:secretsmanager:us-east-2:${local.account_id}:secret:yahoo-fantasy--slop-api-keys-ZTKoqV"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "arn:aws:s3:::connors-misc-blob-for-blobs/zeta_ball/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_zeta_ball_execution" {
  role       = aws_iam_role.lambda_zeta_ball_api_to_sf.name
  policy_arn = aws_iam_policy.lambda_basic_execution_zeta_ball.arn
}

import {
  to = aws_iam_role.lambda_zeta_ball_api_to_sf
  id = "lambda-zeta-ball-api-to-sf-role-065dfwgs"
}

import {
  to = aws_iam_policy.lambda_basic_execution_zeta_ball
  id = "arn:aws:iam::676058464455:policy/service-role/AWSLambdaBasicExecutionRole-3d5f6f34-bf79-4f2d-b275-020911225699"
}

import {
  to = aws_iam_role_policy_attachment.lambda_zeta_ball_execution
  id = "lambda-zeta-ball-api-to-sf-role-065dfwgs/arn:aws:iam::676058464455:policy/service-role/AWSLambdaBasicExecutionRole-3d5f6f34-bf79-4f2d-b275-020911225699"
}
