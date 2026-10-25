resource "aws_secretsmanager_secret" "yahoo_fantasy_slop_api_keys" {
  name        = "yahoo-fantasy--slop-api-keys"
  description = "API credentials to read Yahoo Fantasy API for Zeta Ball (basketball) league"

  recovery_window_in_days        = 30
  force_overwrite_replica_secret = false

  lifecycle {
    ignore_changes = [recovery_window_in_days, force_overwrite_replica_secret]
  }
}

import {
  to = aws_secretsmanager_secret.yahoo_fantasy_slop_api_keys
  id = "yahoo-fantasy--slop-api-keys"
}
