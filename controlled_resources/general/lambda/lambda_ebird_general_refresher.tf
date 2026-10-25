resource "aws_lambda_function" "ebird_general_refresher" {
  function_name = "lambda-ebird-general-refresher"
  role          = "arn:aws:iam::${local.account_id}:role/lambda-ebird-functions-general-role"
  handler       = "lambda_handler.lambda_handler"
  runtime       = "python3.13"
  timeout       = 603
  memory_size   = 128

  filename         = "${path.module}/function_code/ebird-general-refresher/lambda-package.zip"
  source_code_hash = filebase64sha256("${path.module}/function_code/ebird-general-refresher/lambda-package.zip")

  # Layers:
  #   zeta-ball-api-to-sf:1 — reused here for its requests/utility dependencies
  layers = [
    "arn:aws:lambda:${local.region}:${local.account_id}:layer:zeta-ball-api-to-sf:1",
  ]
}

import {
  to = aws_lambda_function.ebird_general_refresher
  id = "lambda-ebird-general-refresher"
}
