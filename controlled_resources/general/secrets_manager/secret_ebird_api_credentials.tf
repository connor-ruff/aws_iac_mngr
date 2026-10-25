resource "aws_secretsmanager_secret" "ebird_api_credentials" {
  name        = "eBird-api-credentials"
  description = "For eBird API, tied with account connorruff"

  recovery_window_in_days        = 30
  force_overwrite_replica_secret = false

  lifecycle {
    ignore_changes = [recovery_window_in_days, force_overwrite_replica_secret]
  }
}

import {
  to = aws_secretsmanager_secret.ebird_api_credentials
  id = "eBird-api-credentials"
}
