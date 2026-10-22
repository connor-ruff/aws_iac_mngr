resource "aws_secretsmanager_secret" "zetaball_walter_api_key" {
  name        = "zetaball-walter-api-key"
  description = "API key (bsbk_...) for the League Data API v1 on Walter's zetaball.com"

  recovery_window_in_days        = 30
  force_overwrite_replica_secret = false

  lifecycle {
    ignore_changes = [recovery_window_in_days, force_overwrite_replica_secret]
  }
}
