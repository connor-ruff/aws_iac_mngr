resource "aws_secretsmanager_secret" "personal_google_drive_service_acct" {
  name        = "Personal-Google-Drive-Service_acct"
  description = "GCP Account: connorruff99@gmail\nProject: Personal-Drive-API\nService Account: personal-drive-service-acct\nKey: 2817a65d23bfd6c4c8cd2d2d8592615c080eac75"

  recovery_window_in_days        = 30
  force_overwrite_replica_secret = false

  lifecycle {
    # Both attributes are write-only — the AWS API never returns them, so OpenTofu
    # cannot read them back and would otherwise always plan a diff.
    ignore_changes = [recovery_window_in_days, force_overwrite_replica_secret]
  }
}

import {
  to = aws_secretsmanager_secret.personal_google_drive_service_acct
  id = "Personal-Google-Drive-Service_acct"
}
