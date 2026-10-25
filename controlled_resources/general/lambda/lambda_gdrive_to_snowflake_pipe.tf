resource "aws_lambda_function" "gdrive_to_snowflake_pipe" {
  function_name = "lambda-gdrive-to-snowflake-pipe"
  role          = "arn:aws:iam::${local.account_id}:role/service-role/lambda-gdrive-to-snowflake-pipe-role-iwl9rkua"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  timeout       = 300
  memory_size   = 128

  filename         = "${path.module}/placeholder.zip"
  source_code_hash = filebase64sha256("${path.module}/placeholder.zip")

  # Layers:
  #   google-api-python-client-layer:2  — Google Drive API client
  #   snowflake-lambda-layer-from-youtube:1 — Snowflake connector (Python 3.8)
  layers = [
    "arn:aws:lambda:${local.region}:${local.account_id}:layer:google-api-python-client-layer:2",
    "arn:aws:lambda:${local.region}:${local.account_id}:layer:snowflake-lambda-layer-from-youtube:1",
  ]

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
}

import {
  to = aws_lambda_function.gdrive_to_snowflake_pipe
  id = "lambda-gdrive-to-snowflake-pipe"
}
