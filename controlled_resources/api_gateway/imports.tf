import {
  to = aws_api_gateway_rest_api.snowflake_ext_func
  id = "1dmrv6cveg"
}

import {
  to = aws_api_gateway_resource.ebird
  id = "1dmrv6cveg/1hlk9o"
}

import {
  to = aws_api_gateway_resource.zeta_ball
  id = "1dmrv6cveg/y7a95z"
}

import {
  to = aws_api_gateway_method.ebird_post
  id = "1dmrv6cveg/1hlk9o/POST"
}

import {
  to = aws_api_gateway_method.zeta_ball_post
  id = "1dmrv6cveg/y7a95z/POST"
}

import {
  to = aws_api_gateway_integration.ebird_post
  id = "1dmrv6cveg/1hlk9o/POST"
}

import {
  to = aws_api_gateway_integration.zeta_ball_post
  id = "1dmrv6cveg/y7a95z/POST"
}

import {
  to = aws_api_gateway_method_response.ebird_post_200
  id = "1dmrv6cveg/1hlk9o/POST/200"
}

import {
  to = aws_api_gateway_method_response.zeta_ball_post_200
  id = "1dmrv6cveg/y7a95z/POST/200"
}

import {
  to = aws_api_gateway_deployment.prod
  id = "1dmrv6cveg/wwy73l"
}

import {
  to = aws_api_gateway_stage.prod
  id = "1dmrv6cveg/prod"
}

# Lambda permissions (format: function-name/statement-id)
import {
  to = aws_lambda_permission.apigw_invoke_ebird
  id = "lambda-ebird-general-refresher/d882d396-c521-5344-81bc-73b781ce9a45"
}

import {
  to = aws_lambda_permission.apigw_invoke_zeta_ball
  id = "lambda-zeta-ball-api-to-sf/76d16d99-8dc0-5502-a8f0-994cf586848c"
}
