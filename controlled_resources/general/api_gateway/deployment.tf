resource "aws_api_gateway_deployment" "prod" {
  rest_api_id = aws_api_gateway_rest_api.snowflake_ext_func.id

  # Redeploy the stage when routes or the resource policy change.
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.snowflake_ext_func.policy,
      aws_api_gateway_resource.zeta_ball.id,
      aws_api_gateway_integration.zeta_ball_post.uri,
      aws_api_gateway_resource.zeta_ball_walter.id,
      aws_api_gateway_integration.zeta_ball_walter_post.uri,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "prod" {
  rest_api_id   = aws_api_gateway_rest_api.snowflake_ext_func.id
  deployment_id = aws_api_gateway_deployment.prod.id
  stage_name    = "prod"
}

import {
  to = aws_api_gateway_stage.prod
  id = "1dmrv6cveg/prod"
}
