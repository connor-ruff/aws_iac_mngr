# Disci

Infrastructure for the Disci app (app code: github.com/connor-ruff/disci). One root, one state (`disci/terraform.tfstate`). Every resource is tagged `project = disci`.

This root owns the **slots**: network, database, login, Lambdas, API, website hosting. The app repo's `scripts/deploy.sh` (run from a laptop or by GitHub Actions) puts **code** into them. Lambda code changes never show up as drift here (`ignore_changes` on the code).

## Files

| File | What |
|---|---|
| `main.tf` | Backend, providers, `default_tags` |
| `variables.tf` | `admin_email` and `invited_emails` (in gitignored `terraform.tfvars`), repo name, budget |
| `network.tf` | Private-only VPC (10.42.0.0/16, 2 subnets, **no IGW/NAT**), security groups, EC2 Instance Connect Endpoint |
| `database.tf` | RDS Postgres 18, db.t4g.micro, IAM auth on, deletion protection |
| `auth.tf` | Cognito user pool (self-signup off: invite-only), hosted login domain, web client, the admin user and one user per invited email |
| `compute.tf` | `disci-api`, `disci-migrator` and `disci-jobs` Lambdas (arm64, Python 3.13, one shared zip), IAM roles, log groups, JSON log format. API (and jobs) env includes `DISCI_MCP_CLIENT_ID` |
| `api.tf` | HTTP API with Cognito JWT authorizer (audience: web client + `disci-mcp` client, since for access tokens API Gateway matches `client_id`), throttling |
| `mcp.tf` | `disci-mcp` Lambda (MCP server for Claude's connector; arm64, Python 3.13, 512 MB, 25 s, **outside the VPC**, own zip), IAM role (basic execution only), log group, JSON log format, routes `ANY /mcp` and `GET /.well-known/{proxy+}` **without** the authorizer (the server does its own auth) |
| `schedules.tf` | EventBridge Scheduler: hourly `disci-jobs` run (recurring transactions), 2 retries |
| `frontend.tf` | Private S3 bucket + CloudFront (OAC, SPA fallback, security headers) |
| `ci.tf` | `disci-github-deploy` role (GitHub OIDC; `connor-ruff/disci` `main` only; code-only permissions on the api, migrator, jobs and mcp Lambdas) |
| `alarms.tf` | SNS topic `disci-alarms` (email to `admin_email`), log metric filter `disci-recurring-failures` → `Disci/RecurringFailures`, and four CloudWatch alarms: `disci-jobs-crashed`, `disci-jobs-user-failures`, `disci-jobs-not-running`, `disci-api-5xx` (what each catches: app repo `docs/ops/deployment.md` §2.4) |
| `budget.tf` | Monthly AWS Budgets alert on `project=disci` (costs and the budget: app repo `docs/ops/cost.md`) |
| `outputs.tf` | Deploy config → SSM `/disci/prod/*` (incl. `lambda_mcp_name` and `mcp_url` = `<api endpoint>/mcp`, the connector URL); outputs |

## Why no NAT gateway

Nothing inside the VPC needs the internet (`disci-mcp`, which does, runs outside it): API Gateway verifies Cognito JWTs before invoking the API Lambda, RDS IAM tokens are signed locally, and config arrives as Lambda environment variables. That saves ~$33/mo.

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
- AWS emails `admin_email` a confirmation link for the `disci-alarms` SNS subscription; alarm emails start once it's clicked.
- Activate the `project` cost allocation tag once it appears (up to 24h) so the budget filter matches: app repo `docs/ops/cost.md` §5. Tracked in `documentation/manual-actions.md` (the Billing console page may be blocked; use the `ce` CLI).

## Inviting people

Sign-up is invite-only. To let someone in, add their email to `invited_emails` in `terraform.tfvars` (gitignored, since this repo is public), then plan and apply. Cognito emails them a temporary password, valid 7 days; they set their own at first sign-in. If it expires before they sign in, re-send it with `aws cognito-idp admin-create-user --user-pool-id <pool> --username <email> --message-action RESEND`.

Removing an email deletes that Cognito user, so they can no longer sign in. Their app data stays in the database.

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
