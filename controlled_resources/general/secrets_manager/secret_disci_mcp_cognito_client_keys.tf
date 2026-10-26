resource "aws_secretsmanager_secret" "disci_mcp_cognito_client_keys" {
  name        = "disci-mcp-cognito-client-keys"
  description = "Client ID and secret of the disci-mcp Cognito app client (Claude custom connector). Source: tofu output mcp_client_id / mcp_client_secret in controlled_resources/disci"

  recovery_window_in_days        = 30
  force_overwrite_replica_secret = false

  tags = {
    project = "disci"
  }

  lifecycle {
    ignore_changes = [recovery_window_in_days, force_overwrite_replica_secret]
  }
}
