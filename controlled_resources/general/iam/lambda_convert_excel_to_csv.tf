resource "aws_iam_role" "lambda_convert_excel_bytes_to_csv" {
  name = "lambda-convert-excel-bytes-to-csv-role-vod6a7wk"
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

resource "aws_iam_policy" "lambda_basic_execution_excel_to_csv" {
  name = "AWSLambdaBasicExecutionRole-ea0f76ca-62c7-4528-bbe9-31bbfc6b3779"
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
          "arn:aws:logs:us-east-2:${local.account_id}:log-group:/aws/lambda/lambda-convert-excel-bytes-to-csv:*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_excel_to_csv_basic_execution" {
  role       = aws_iam_role.lambda_convert_excel_bytes_to_csv.name
  policy_arn = aws_iam_policy.lambda_basic_execution_excel_to_csv.arn
}

import {
  to = aws_iam_role.lambda_convert_excel_bytes_to_csv
  id = "lambda-convert-excel-bytes-to-csv-role-vod6a7wk"
}

import {
  to = aws_iam_policy.lambda_basic_execution_excel_to_csv
  id = "arn:aws:iam::676058464455:policy/service-role/AWSLambdaBasicExecutionRole-ea0f76ca-62c7-4528-bbe9-31bbfc6b3779"
}

import {
  to = aws_iam_role_policy_attachment.lambda_excel_to_csv_basic_execution
  id = "lambda-convert-excel-bytes-to-csv-role-vod6a7wk/arn:aws:iam::676058464455:policy/service-role/AWSLambdaBasicExecutionRole-ea0f76ca-62c7-4528-bbe9-31bbfc6b3779"
}
