resource "aws_secretsmanager_secret" "snowflake_prog_user" {
  name        = "snowflake-PROG_USER"
  description = "Credentials for the PROG_USER service account on snowflake. NOTE: \\n in rsa keys are replaced with ^NEWLINECHAR^"

  recovery_window_in_days        = 30
  force_overwrite_replica_secret = false

  lifecycle {
    ignore_changes = [recovery_window_in_days, force_overwrite_replica_secret]
  }
}

import {
  to = aws_secretsmanager_secret.snowflake_prog_user
  id = "snowflake-PROG_USER"
}
