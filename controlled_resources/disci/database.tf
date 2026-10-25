# Master user `disci` owns the schema and runs migrations (via the migrator Lambda).
# The API connects as `disci_api` with IAM auth (no password); that role is created by
# the migrator on every run. The master password lives only in the encrypted state
# and the migrator's environment.
resource "random_password" "db_master" {
  length  = 40
  special = false # keeps it URL-safe for connection strings
}

resource "aws_db_subnet_group" "main" {
  name       = local.name
  subnet_ids = aws_subnet.private[*].id
}

resource "aws_db_instance" "main" {
  identifier     = local.name
  engine         = "postgres"
  engine_version = "18" # major only; minor versions auto-upgrade in the maintenance window
  instance_class = "db.t4g.micro"

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = "disci"
  username = "disci"
  password = random_password.db_master.result

  iam_database_authentication_enabled = true

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  multi_az               = false

  backup_retention_period    = 7
  backup_window              = "08:00-08:30"         # UTC (~3am Central)
  maintenance_window         = "sun:09:00-sun:09:30" # UTC
  auto_minor_version_upgrade = true
  copy_tags_to_snapshot      = true

  deletion_protection       = true
  skip_final_snapshot       = false
  final_snapshot_identifier = "${local.name}-final"
}
