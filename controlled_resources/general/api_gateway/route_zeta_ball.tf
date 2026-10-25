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

resource "aws_lambda_permission" "apigw_invoke_zeta_ball" {
  statement_id  = "76d16d99-8dc0-5502-a8f0-994cf586848c"
  action        = "lambda:InvokeFunction"
  function_name = "lambda-zeta-ball-api-to-sf"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${local.region}:${local.account_id}:${local.api_id}/*/POST/lambda-zeta-ball-refresh"
}

import {
  to = aws_api_gateway_resource.zeta_ball
  id = "1dmrv6cveg/y7a95z"
}

import {
  to = aws_api_gateway_method.zeta_ball_post
  id = "1dmrv6cveg/y7a95z/POST"
}

import {
  to = aws_api_gateway_integration.zeta_ball_post
  id = "1dmrv6cveg/y7a95z/POST"
}

import {
  to = aws_api_gateway_method_response.zeta_ball_post_200
  id = "1dmrv6cveg/y7a95z/POST/200"
}

import {
  to = aws_lambda_permission.apigw_invoke_zeta_ball
  id = "lambda-zeta-ball-api-to-sf/76d16d99-8dc0-5502-a8f0-994cf586848c"
}
