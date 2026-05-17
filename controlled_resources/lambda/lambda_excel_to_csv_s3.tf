resource "aws_lambda_function" "excel_to_csv_s3" {
  function_name = "lambda-excel-to-csv-s3"
  role          = "arn:aws:iam::${local.account_id}:role/lambda-excel-to-csv-s3-role"
  handler       = "lambda_handler.lambda_handler"
  runtime       = "python3.12"
  timeout       = 120
  memory_size   = 256

  filename         = "${path.module}/function_code/excel-to-csv-s3/lambda-package.zip"
  source_code_hash = filebase64sha256("${path.module}/function_code/excel-to-csv-s3/lambda-package.zip")

  # Layers:
  #   AWSSDKPandas-Python312 — AWS-managed layer; includes pandas + openpyxl
  #   Check latest version: aws lambda list-layers --compatible-runtime python3.12
  layers = [
    "arn:aws:lambda:${local.region}:336392948345:layer:AWSSDKPandas-Python312:24",
  ]
}
