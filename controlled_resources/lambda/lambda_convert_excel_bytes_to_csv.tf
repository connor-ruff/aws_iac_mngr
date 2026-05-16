resource "aws_lambda_function" "convert_excel_bytes_to_csv" {
  function_name = "lambda-convert-excel-bytes-to-csv"
  role          = "arn:aws:iam::${local.account_id}:role/service-role/lambda-convert-excel-bytes-to-csv-role-vod6a7wk"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  timeout       = 63
  memory_size   = 128

  filename         = "${path.module}/placeholder.zip"
  source_code_hash = filebase64sha256("${path.module}/placeholder.zip")

  # Layers:
  #   AWSSDKPandas-Python39:20 — AWS-managed pandas layer (account 336392948345)
  layers = [
    "arn:aws:lambda:${local.region}:336392948345:layer:AWSSDKPandas-Python39:20",
  ]

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
}

import {
  to = aws_lambda_function.convert_excel_bytes_to_csv
  id = "lambda-convert-excel-bytes-to-csv"
}
