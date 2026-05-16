resource "aws_api_gateway_rest_api" "snowflake_ext_func" {
  name        = "snowflake-ext-func-trigger"
  description = "This will be used for all Snowflake external functions that are designed to trigger an AWS lambda function"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  # Resource policy: allows sf-external-function-role (assumed by Snowflake) to
  # invoke both POST routes.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:sts::${local.account_id}:assumed-role/sf-external-function-role/snowflake" }
        Action    = "execute-api:Invoke"
        Resource  = "arn:aws:execute-api:${local.region}:${local.account_id}:${local.api_id}/*/POST/lambda-zeta-ball-refresh"
      },
      {
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:sts::${local.account_id}:assumed-role/sf-external-function-role/snowflake" }
        Action    = "execute-api:Invoke"
        Resource  = "arn:aws:execute-api:${local.region}:${local.account_id}:${local.api_id}/*/POST/lambda-ebird-general-refresher"
      }
    ]
  })
}

# ---
# /lambda-ebird-general-refresher
# ---

resource "aws_api_gateway_resource" "ebird" {
  rest_api_id = aws_api_gateway_rest_api.snowflake_ext_func.id
  parent_id   = aws_api_gateway_rest_api.snowflake_ext_func.root_resource_id
  path_part   = "lambda-ebird-general-refresher"
}

resource "aws_api_gateway_method" "ebird_post" {
  rest_api_id   = aws_api_gateway_rest_api.snowflake_ext_func.id
  resource_id   = aws_api_gateway_resource.ebird.id
  http_method   = "POST"
  authorization = "AWS_IAM"
}

resource "aws_api_gateway_integration" "ebird_post" {
  rest_api_id             = aws_api_gateway_rest_api.snowflake_ext_func.id
  resource_id             = aws_api_gateway_resource.ebird.id
  http_method             = aws_api_gateway_method.ebird_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${local.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${local.region}:${local.account_id}:function:lambda-ebird-general-refresher/invocations"
  passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_TEXT"
  timeout_milliseconds    = 29000
}

resource "aws_api_gateway_method_response" "ebird_post_200" {
  rest_api_id = aws_api_gateway_rest_api.snowflake_ext_func.id
  resource_id = aws_api_gateway_resource.ebird.id
  http_method = aws_api_gateway_method.ebird_post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

# ---
# /lambda-zeta-ball-refresh
# ---

resource "aws_api_gateway_resource" "zeta_ball" {
  rest_api_id = aws_api_gateway_rest_api.snowflake_ext_func.id
  parent_id   = aws_api_gateway_rest_api.snowflake_ext_func.root_resource_id
  path_part   = "lambda-zeta-ball-refresh"
}

resource "aws_api_gateway_method" "zeta_ball_post" {
  rest_api_id   = aws_api_gateway_rest_api.snowflake_ext_func.id
  resource_id   = aws_api_gateway_resource.zeta_ball.id
  http_method   = "POST"
  authorization = "AWS_IAM"
}

resource "aws_api_gateway_integration" "zeta_ball_post" {
  rest_api_id             = aws_api_gateway_rest_api.snowflake_ext_func.id
  resource_id             = aws_api_gateway_resource.zeta_ball.id
  http_method             = aws_api_gateway_method.zeta_ball_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${local.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${local.region}:${local.account_id}:function:lambda-zeta-ball-api-to-sf/invocations"
  passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_TEXT"
  timeout_milliseconds    = 29000
}

resource "aws_api_gateway_method_response" "zeta_ball_post_200" {
  rest_api_id = aws_api_gateway_rest_api.snowflake_ext_func.id
  resource_id = aws_api_gateway_resource.zeta_ball.id
  http_method = aws_api_gateway_method.zeta_ball_post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

# ---
# Deployment and stage
# ---

resource "aws_api_gateway_deployment" "prod" {
  rest_api_id = aws_api_gateway_rest_api.snowflake_ext_func.id
}

resource "aws_api_gateway_stage" "prod" {
  rest_api_id   = aws_api_gateway_rest_api.snowflake_ext_func.id
  deployment_id = aws_api_gateway_deployment.prod.id
  stage_name    = "prod"
}

# ---
# Lambda invoke permissions
# These allow API Gateway to call each Lambda function.
# ---

resource "aws_lambda_permission" "apigw_invoke_ebird" {
  statement_id  = "d882d396-c521-5344-81bc-73b781ce9a45"
  action        = "lambda:InvokeFunction"
  function_name = "lambda-ebird-general-refresher"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${local.region}:${local.account_id}:${local.api_id}/*/POST/lambda-ebird-general-refresher"
}

resource "aws_lambda_permission" "apigw_invoke_zeta_ball" {
  statement_id  = "76d16d99-8dc0-5502-a8f0-994cf586848c"
  action        = "lambda:InvokeFunction"
  function_name = "lambda-zeta-ball-api-to-sf"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${local.region}:${local.account_id}:${local.api_id}/*/POST/lambda-zeta-ball-refresh"
}
