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

resource "aws_lambda_permission" "apigw_invoke_ebird" {
  statement_id  = "d882d396-c521-5344-81bc-73b781ce9a45"
  action        = "lambda:InvokeFunction"
  function_name = "lambda-ebird-general-refresher"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${local.region}:${local.account_id}:${local.api_id}/*/POST/lambda-ebird-general-refresher"
}

import {
  to = aws_api_gateway_resource.ebird
  id = "1dmrv6cveg/1hlk9o"
}

import {
  to = aws_api_gateway_method.ebird_post
  id = "1dmrv6cveg/1hlk9o/POST"
}

import {
  to = aws_api_gateway_integration.ebird_post
  id = "1dmrv6cveg/1hlk9o/POST"
}

import {
  to = aws_api_gateway_method_response.ebird_post_200
  id = "1dmrv6cveg/1hlk9o/POST/200"
}

import {
  to = aws_lambda_permission.apigw_invoke_ebird
  id = "lambda-ebird-general-refresher/d882d396-c521-5344-81bc-73b781ce9a45"
}
