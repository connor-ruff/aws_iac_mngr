resource "aws_lambda_function" "zeta_ball_api_to_sf" {
  function_name = "lambda-zeta-ball-api-to-sf"
  role          = "arn:aws:iam::${local.account_id}:role/service-role/lambda-zeta-ball-api-to-sf-role-065dfwgs"
  handler       = "lambda_handler.lambda_handler"
  runtime       = "python3.13"
  timeout       = 243
  memory_size   = 128

  filename         = "${path.module}/function_code/zeta-ball-api-to-sf/lambda-package.zip"
  source_code_hash = filebase64sha256("${path.module}/function_code/zeta-ball-api-to-sf/lambda-package.zip")

  # Layers:
  #   zeta-ball-api-to-sf:1              — Zeta Ball API dependencies
  #   snowflake-connector-python-3-13:2  — Snowflake connector (Python 3.13)
  layers = [
    "arn:aws:lambda:${local.region}:${local.account_id}:layer:zeta-ball-api-to-sf:1",
    "arn:aws:lambda:${local.region}:${local.account_id}:layer:snowflake-connector-python-3-13:2",
  ]
}

import {
  to = aws_lambda_function.zeta_ball_api_to_sf
  id = "lambda-zeta-ball-api-to-sf"
}
