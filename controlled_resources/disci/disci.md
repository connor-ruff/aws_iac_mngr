# Disci

Infrastructure for the Disci app (app code: github.com/connor-ruff/disci). One root, one state (`disci/terraform.tfstate`). Every resource is tagged `project = disci`.

This root owns the **slots**: network, database, login, Lambdas, API, website hosting. The app repo's `scripts/deploy.sh` (run from a laptop or by GitHub Actions) puts **code** into them. Lambda code changes never show up as drift here (`ignore_changes` on the code).

## Files

| File | What |
|---|---|
| `main.tf` | Backend, providers, `default_tags` |
| `variables.tf` | `admin_email` (in gitignored `terraform.tfvars`), repo name, budget |
| `network.tf` | Private-only VPC (10.42.0.0/16, 2 subnets, **no IGW/NAT**), security groups, EC2 Instance Connect Endpoint |
| `database.tf` | RDS Postgres 18, db.t4g.micro, IAM auth on, deletion protection |
| `auth.tf` | Cognito user pool (self-signup off), hosted login domain, web client, first user |
| `compute.tf` | `disci-api`, `disci-migrator` and `disci-jobs` Lambdas (arm64, Python 3.13, one shared zip), IAM roles, log groups |
| `api.tf` | HTTP API with Cognito JWT authorizer, throttling |
| `schedules.tf` | EventBridge Scheduler: hourly `disci-jobs` run (recurring transactions), 2 retries |
| `frontend.tf` | Private S3 bucket + CloudFront (OAC, SPA fallback, security headers) |
| `ci.tf` | `disci-github-deploy` role (GitHub OIDC; `connor-ruff/disci` `main` only; code-only permissions) |
| `budget.tf` | Monthly AWS Budgets alert on `project=disci` |
| `outputs.tf` | Deploy config → SSM `/disci/prod/*`; outputs |

## Why no NAT gateway

Nothing inside the VPC needs the internet: API Gateway verifies Cognito JWTs before invoking the API Lambda, RDS IAM tokens are signed locally, and config arrives as Lambda environment variables. That saves ~$33/mo.

## Applying

```bash
# first time only: admin_resources/github_oidc must be applied before this root
cp terraform.tfvars.example terraform.tfvars   # set admin_email
tofu init
tofu plan -out=tfplan
tofu apply tfplan
```

After the first apply:
- Cognito emails `admin_email` a temporary password (set a real one at first sign-in).
- Activate the `project` cost allocation tag (Billing → Cost allocation tags) once it appears (up to 24h) so the budget filter matches.

## Connecting to the database from a laptop

RDS is private. Tunnel through the Instance Connect Endpoint (no bastion, no hourly cost):

```bash
aws ec2-instance-connect open-tunnel \
  --instance-connect-endpoint-id $(tofu output -raw eice_id) \
  --private-ip-address $(dig +short $(tofu output -raw rds_endpoint) | tail -1) \
  --remote-port 5432 --local-port 5433 --profile connor-ruff-dev-acct --region us-east-2
# then, in another terminal (master user):
PGPASSWORD=$(tofu output -raw db_master_password) psql "host=localhost port=5433 dbname=disci user=disci sslmode=require"
```

Tunnels last up to 1 hour.
