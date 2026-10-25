resource "aws_iam_role" "lambda_gdrive_to_snowflake_pipe" {
  name = "lambda-gdrive-to-snowflake-pipe-role-iwl9rkua"
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

# Despite the "BasicExecutionRole" name, this policy was expanded over time to
# include SecretsManager, S3, and Lambda permissions needed by the GDrive pipeline.
resource "aws_iam_policy" "lambda_basic_execution_gdrive_snowflake" {
  name = "AWSLambdaBasicExecutionRole-8c647545-38f1-4b95-bd7a-f3ebfe3f808a"
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
          "arn:aws:logs:us-east-2:${local.account_id}:log-group:/aws/lambda/lambda-gdrive-to-snowflake-pipe:*"
        ]
      },
      {
        Effect = "Allow"
        Action = "secretsmanager:GetSecretValue"
        Resource = [
          "arn:aws:secretsmanager:us-east-2:${local.account_id}:secret:Personal-Google-Drive-Service_acct-BL6hzH",
          "arn:aws:secretsmanager:us-east-2:${local.account_id}:secret:snowflake-PROG_USER-wimL7F",
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:PutObjectAcl"]
        Resource = [
          "arn:aws:s3:::connors-big-money-data-bucket/*",
          "arn:aws:s3:::connors-misc-blob-for-blobs/*",
        ]
      },
      {
        Effect   = "Allow"
        Action   = "lambda:InvokeFunction"
        Resource = "arn:aws:lambda:us-east-2:${local.account_id}:function:lambda-convert-excel-bytes-to-csv"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_gdrive_snowflake_execution" {
  role       = aws_iam_role.lambda_gdrive_to_snowflake_pipe.name
  policy_arn = aws_iam_policy.lambda_basic_execution_gdrive_snowflake.arn
}

import {
  to = aws_iam_role.lambda_gdrive_to_snowflake_pipe
  id = "lambda-gdrive-to-snowflake-pipe-role-iwl9rkua"
}

import {
  to = aws_iam_policy.lambda_basic_execution_gdrive_snowflake
  id = "arn:aws:iam::676058464455:policy/service-role/AWSLambdaBasicExecutionRole-8c647545-38f1-4b95-bd7a-f3ebfe3f808a"
}

import {
  to = aws_iam_role_policy_attachment.lambda_gdrive_snowflake_execution
  id = "lambda-gdrive-to-snowflake-pipe-role-iwl9rkua/arn:aws:iam::676058464455:policy/service-role/AWSLambdaBasicExecutionRole-8c647545-38f1-4b95-bd7a-f3ebfe3f808a"
}
