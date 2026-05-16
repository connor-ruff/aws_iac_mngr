resource "aws_api_gateway_deployment" "prod" {
  rest_api_id = aws_api_gateway_rest_api.snowflake_ext_func.id
}

resource "aws_api_gateway_stage" "prod" {
  rest_api_id   = aws_api_gateway_rest_api.snowflake_ext_func.id
  deployment_id = aws_api_gateway_deployment.prod.id
  stage_name    = "prod"
}

import {
  to = aws_api_gateway_deployment.prod
  id = "1dmrv6cveg/wwy73l"
}

import {
  to = aws_api_gateway_stage.prod
  id = "1dmrv6cveg/prod"
}
