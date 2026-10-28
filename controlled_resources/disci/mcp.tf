# MCP server for Claude's custom connector (app repo's `mcp_server/`). Its own Lambda,
# outside the VPC: it needs the internet (Cognito JWKS, the public API URL) and never
# touches the database. Its tools call the Disci API with the caller's access token.
#
# Routes on the existing HTTP API, without the JWT authorizer: the MCP server must answer
# unauthenticated requests itself (a 401 with WWW-Authenticate pointing at its OAuth
# metadata), and it verifies every token itself.
#   ANY /mcp                 the MCP endpoint (connector URL: <api_url>/mcp)
#   GET /.well-known/{proxy+} OAuth protected-resource metadata

data "archive_file" "mcp_placeholder" {
  type        = "zip"
  output_path = "${path.module}/.build/mcp-placeholder.zip"

  source {
    filename = "disci_mcp/lambda_handler.py"
    content  = "def handler(event, context):\n    return {'statusCode': 503, 'body': 'not deployed yet'}\n"
  }
  source {
    filename = "disci_mcp/__init__.py"
    content  = ""
  }
}

resource "aws_iam_role" "mcp" {
  name               = "${local.name}-mcp-lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy_attachment" "mcp_logs" {
  role       = aws_iam_role.mcp.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_log_group" "mcp" {
  name              = "/aws/lambda/${local.name}-mcp"
  retention_in_days = 14
}

resource "aws_lambda_function" "mcp" {
  function_name = "${local.name}-mcp"
  role          = aws_iam_role.mcp.arn
  handler       = "disci_mcp.lambda_handler.handler"
  runtime       = "python3.13"
  architectures = ["arm64"]
  memory_size   = 512
  timeout       = 25 # under API Gateway's 30 s

  # JSON lines: Lambda adds `requestId`, and Python logging's `extra=` fields become keys.
  # Application log level is left to the code (INFO, set in each handler).
  logging_config {
    log_format = "JSON"
  }

  filename         = data.archive_file.mcp_placeholder.output_path
  source_code_hash = data.archive_file.mcp_placeholder.output_base64sha256

  environment {
    variables = {
      DISCI_MCP_ENV               = "prod"
      DISCI_MCP_AUTH_MODE         = "cognito"
      DISCI_MCP_PUBLIC_URL        = aws_apigatewayv2_api.main.api_endpoint
      DISCI_MCP_API_URL           = aws_apigatewayv2_api.main.api_endpoint
      DISCI_MCP_COGNITO_ISSUER    = "https://${aws_cognito_user_pool.main.endpoint}"
      DISCI_MCP_COGNITO_CLIENT_ID = aws_cognito_user_pool_client.mcp.id
    }
  }

  depends_on = [aws_cloudwatch_log_group.mcp]

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
}

resource "aws_apigatewayv2_integration" "mcp" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.mcp.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "mcp" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "ANY /mcp"
  target    = "integrations/${aws_apigatewayv2_integration.mcp.id}"
}

resource "aws_apigatewayv2_route" "mcp_well_known" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "GET /.well-known/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.mcp.id}"
}

resource "aws_lambda_permission" "mcp_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.mcp.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}
