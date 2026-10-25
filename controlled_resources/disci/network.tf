# Private-only VPC: no internet gateway, no NAT (~$33/mo avoided), no public IPs.
# Lambdas and RDS talk to each other inside it; nothing inside needs the internet:
#   - API Gateway verifies Cognito JWTs before invoking the API Lambda (no JWKS fetch)
#   - RDS IAM auth tokens are signed locally (no AWS API call)
#   - config arrives as Lambda environment variables (no SSM call)
# Laptop access to RDS goes through the EC2 Instance Connect Endpoint (no hourly cost).

resource "aws_vpc" "main" {
  cidr_block           = "10.42.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = local.name }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Two AZs because an RDS subnet group requires them (the instance itself is single-AZ).
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 1)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags              = { Name = "${local.name}-private-${count.index + 1}" }
}

# --- Security groups -----------------------------------------------------------

resource "aws_security_group" "lambda" {
  name        = "${local.name}-lambda"
  description = "Disci Lambdas (api, migrator)"
  vpc_id      = aws_vpc.main.id
}

resource "aws_security_group" "rds" {
  name        = "${local.name}-rds"
  description = "Disci Postgres"
  vpc_id      = aws_vpc.main.id
}

resource "aws_security_group" "eice" {
  name        = "${local.name}-eice"
  description = "EC2 Instance Connect Endpoint (laptop tunnel to RDS)"
  vpc_id      = aws_vpc.main.id
}

resource "aws_vpc_security_group_egress_rule" "lambda_to_rds" {
  security_group_id            = aws_security_group.lambda.id
  referenced_security_group_id = aws_security_group.rds.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_lambda" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = aws_security_group.lambda.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}

resource "aws_vpc_security_group_egress_rule" "eice_to_rds" {
  security_group_id            = aws_security_group.eice.id
  referenced_security_group_id = aws_security_group.rds.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_eice" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = aws_security_group.eice.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}

# --- Laptop access ---------------------------------------------------------------

resource "aws_ec2_instance_connect_endpoint" "main" {
  subnet_id          = aws_subnet.private[0].id
  security_group_ids = [aws_security_group.eice.id]
  preserve_client_ip = false
  tags               = { Name = local.name }
}
