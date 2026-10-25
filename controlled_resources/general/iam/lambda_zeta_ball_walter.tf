resource "aws_iam_role" "lambda_zeta_ball_walter_api_to_sf" {
  name = "lambda-zeta-ball-walter-api-to-sf-role"

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

resource "aws_iam_policy" "lambda_zeta_ball_walter_api_to_sf_execution" {
  name = "lambda-zeta-ball-walter-api-to-sf-execution"

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
          "arn:aws:logs:us-east-2:${local.account_id}:log-group:/aws/lambda/lambda-zeta-ball-walter-api-to-sf:*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = "arn:aws:secretsmanager:us-east-2:${local.account_id}:secret:zetaball-walter-api-key-H0fsmK"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "arn:aws:s3:::connors-misc-blob-for-blobs/zeta_ball_walter/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_zeta_ball_walter_api_to_sf_execution" {
  role       = aws_iam_role.lambda_zeta_ball_walter_api_to_sf.name
  policy_arn = aws_iam_policy.lambda_zeta_ball_walter_api_to_sf_execution.arn
}
