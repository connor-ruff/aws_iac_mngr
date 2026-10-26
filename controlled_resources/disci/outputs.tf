# Values the app repo's deploy script (laptop or CI) needs, published to SSM under
# /disci/prod/. Nothing secret goes here.

locals {
  deploy_config = {
    region                     = local.region
    api_url                    = aws_apigatewayv2_api.main.api_endpoint
    web_url                    = local.web_origin
    web_bucket                 = aws_s3_bucket.web.bucket
    cloudfront_distribution_id = aws_cloudfront_distribution.web.id
    cognito_user_pool_id       = aws_cognito_user_pool.main.id
    cognito_client_id          = aws_cognito_user_pool_client.web.id
    cognito_domain             = "https://${aws_cognito_user_pool_domain.main.domain}.auth.${local.region}.amazoncognito.com"
    lambda_api_name            = aws_lambda_function.api.function_name
    lambda_migrator_name       = aws_lambda_function.migrator.function_name
    lambda_jobs_name           = aws_lambda_function.jobs.function_name
    lambda_mcp_name            = aws_lambda_function.mcp.function_name
    mcp_url                    = "${aws_apigatewayv2_api.main.api_endpoint}/mcp"
  }
}

resource "aws_ssm_parameter" "deploy_config" {
  for_each = local.deploy_config
  name     = "/disci/prod/${each.key}"
  type     = "String"
  value    = each.value
}

output "deploy_config" {
  value = local.deploy_config
}

output "github_deploy_role_arn" {
  value = aws_iam_role.deploy.arn
}

output "rds_endpoint" {
  value = aws_db_instance.main.address
}

output "eice_id" {
  description = "For: aws ec2-instance-connect open-tunnel --instance-connect-endpoint-id <id> ..."
  value       = aws_ec2_instance_connect_endpoint.main.id
}

output "db_master_password" {
  description = "tofu output -raw db_master_password (laptop access via the EICE tunnel)"
  value       = random_password.db_master.result
  sensitive   = true
}

output "mcp_client_id" {
  description = "Cognito client for Claude's custom connector (enter in Advanced settings)"
  value       = aws_cognito_user_pool_client.mcp.id
}

output "mcp_client_secret" {
  description = "tofu output -raw mcp_client_secret (enter in the connector's Advanced settings)"
  value       = aws_cognito_user_pool_client.mcp.client_secret
  sensitive   = true
}
