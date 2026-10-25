resource "aws_lambda_function" "zeta_ball_walter_api_to_sf" {
  function_name = "lambda-zeta-ball-walter-api-to-sf"
  role          = "arn:aws:iam::${local.account_id}:role/lambda-zeta-ball-walter-api-to-sf-role"
  handler       = "lambda_handler.lambda_handler"
  runtime       = "python3.13"
  timeout       = 60
  memory_size   = 128

  filename         = "${path.module}/function_code/zeta-ball-walter-api-to-sf/lambda-package.zip"
  source_code_hash = filebase64sha256("${path.module}/function_code/zeta-ball-walter-api-to-sf/lambda-package.zip")
}
