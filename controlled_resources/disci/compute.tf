# Three Lambdas built from the same zip (the app repo's `api/`):
#   disci-api       FastAPI behind API Gateway (handler app.lambda_handler.handler)
#   disci-migrator  creates DB roles, runs dbmate migrations (handler app.migrator.handler)
#   disci-jobs      scheduled work: hourly recurring transactions (app.jobs.recurring.handler)
# OpenTofu creates them with a placeholder; the app repo's deploy script uploads real code,
# so code changes never show up as drift here.

data "archive_file" "placeholder" {
  type        = "zip"
  output_path = "${path.module}/.build/placeholder.zip"

  source {
    filename = "app/lambda_handler.py"
    content  = "def handler(event, context):\n    return {'statusCode': 503, 'body': 'not deployed yet'}\n"
  }
  source {
    filename = "app/migrator.py"
    content  = "def handler(event, context):\n    raise RuntimeError('not deployed yet')\n"
  }
  source {
    filename = "app/__init__.py"
    content  = ""
  }
  source {
    filename = "app/jobs/recurring.py"
    content  = "def handler(event, context):\n    return 'not deployed yet'\n"
  }
  source {
    filename = "app/jobs/__init__.py"
    content  = ""
  }
}

locals {
  db_endpoint = "${aws_db_instance.main.address}:${aws_db_instance.main.port}"
}

# --- disci-api -------------------------------------------------------------------

resource "aws_iam_role" "api" {
  name               = "${local.name}-api-lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy_attachment" "api_vpc" {
  role       = aws_iam_role.api.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "api_rds_connect" {
  name = "rds-iam-connect"
  role = aws_iam_role.api.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "rds-db:connect"
      Resource = "arn:aws:rds-db:${local.region}:${local.account_id}:dbuser:${aws_db_instance.main.resource_id}/disci_api"
    }]
  })
}

resource "aws_cloudwatch_log_group" "api" {
  name              = "/aws/lambda/${local.name}-api"
  retention_in_days = 14
}

resource "aws_lambda_function" "api" {
  function_name = "${local.name}-api"
  role          = aws_iam_role.api.arn
  handler       = "app.lambda_handler.handler"
  runtime       = "python3.13"
  architectures = ["arm64"]
  memory_size   = 512
  timeout       = 15

  # JSON lines: Lambda adds `requestId`, and Python logging's `extra=` fields become keys.
  # Application log level is left to the code (INFO, set in each handler).
  logging_config {
    log_format = "JSON"
  }

  filename         = data.archive_file.placeholder.output_path
  source_code_hash = data.archive_file.placeholder.output_base64sha256

  vpc_config {
    subnet_ids         = aws_subnet.private[*].id
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      DISCI_ENV          = "prod"
      DISCI_AUTH_MODE    = "cognito"
      DISCI_DB_IAM_AUTH  = "true"
      DISCI_DATABASE_URL = "postgresql://disci_api@${local.db_endpoint}/disci?sslmode=require"
      DISCI_CORS_ORIGINS = jsonencode([local.web_origin])
      # Access tokens from this client (forwarded by the MCP server) are accepted.
      DISCI_MCP_CLIENT_ID = aws_cognito_user_pool_client.mcp.id
    }
  }

  depends_on = [aws_cloudwatch_log_group.api]

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
}

# --- disci-migrator ------------------------------------------------------------------

resource "aws_iam_role" "migrator" {
  name               = "${local.name}-migrator-lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy_attachment" "migrator_vpc" {
  role       = aws_iam_role.migrator.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_cloudwatch_log_group" "migrator" {
  name              = "/aws/lambda/${local.name}-migrator"
  retention_in_days = 14
}

resource "aws_lambda_function" "migrator" {
  function_name = "${local.name}-migrator"
  role          = aws_iam_role.migrator.arn
  handler       = "app.migrator.handler"
  runtime       = "python3.13"
  architectures = ["arm64"]
  memory_size   = 512
  timeout       = 300

  # JSON lines: Lambda adds `requestId`, and Python logging's `extra=` fields become keys.
  # Application log level is left to the code (INFO, set in each handler).
  logging_config {
    log_format = "JSON"
  }

  filename         = data.archive_file.placeholder.output_path
  source_code_hash = data.archive_file.placeholder.output_base64sha256

  vpc_config {
    subnet_ids         = aws_subnet.private[*].id
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      DISCI_MIGRATOR_DATABASE_URL = "postgresql://disci:${random_password.db_master.result}@${local.db_endpoint}/disci?sslmode=require"
    }
  }

  depends_on = [aws_cloudwatch_log_group.migrator]

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
}

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# --- disci-jobs (scheduled work, e.g. hourly recurring transactions) -----------------

resource "aws_iam_role" "jobs" {
  name               = "${local.name}-jobs-lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy_attachment" "jobs_vpc" {
  role       = aws_iam_role.jobs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Same database login as the API: RLS applies to jobs exactly as to requests.
resource "aws_iam_role_policy" "jobs_rds_connect" {
  name   = "rds-iam-connect"
  role   = aws_iam_role.jobs.id
  policy = aws_iam_role_policy.api_rds_connect.policy
}

resource "aws_cloudwatch_log_group" "jobs" {
  name              = "/aws/lambda/${local.name}-jobs"
  retention_in_days = 14
}

resource "aws_lambda_function" "jobs" {
  function_name = "${local.name}-jobs"
  role          = aws_iam_role.jobs.arn
  handler       = "app.jobs.recurring.handler"
  runtime       = "python3.13"
  architectures = ["arm64"]
  memory_size   = 512
  timeout       = 120

  # JSON lines: Lambda adds `requestId`, and Python logging's `extra=` fields become keys.
  # Application log level is left to the code (INFO, set in each handler).
  logging_config {
    log_format = "JSON"
  }

  filename         = data.archive_file.placeholder.output_path
  source_code_hash = data.archive_file.placeholder.output_base64sha256

  vpc_config {
    subnet_ids         = aws_subnet.private[*].id
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = aws_lambda_function.api.environment[0].variables
  }

  depends_on = [aws_cloudwatch_log_group.jobs]

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
}
