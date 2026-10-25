resource "aws_iam_role" "lambda_excel_to_csv_s3" {
  name = "lambda-excel-to-csv-s3-role"

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

resource "aws_iam_policy" "lambda_excel_to_csv_s3_execution" {
  name = "lambda-excel-to-csv-s3-execution"

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
          "arn:aws:logs:us-east-2:${local.account_id}:log-group:/aws/lambda/lambda-excel-to-csv-s3:*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = "arn:aws:s3:::*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:DeleteObject"]
        Resource = "arn:aws:s3:::*/*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:CopyObject"]
        Resource = "arn:aws:s3:::*/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_excel_to_csv_s3_execution" {
  role       = aws_iam_role.lambda_excel_to_csv_s3.name
  policy_arn = aws_iam_policy.lambda_excel_to_csv_s3_execution.arn
}
