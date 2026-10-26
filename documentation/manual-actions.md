# Manual actions

Things that have to be done by hand (console clicks, root-only settings, account-level toggles, or CLI calls that change settings OpenTofu doesn't manage). Anything here is **not** reproduced by `tofu apply`, so a rebuilt or new account needs these repeated.

`aws` CLI commands are also logged in `aws-cli-commands/`; link the log file from the entry when one exists.

## Pending

| Action | Needed by | Blocked on | How |
|---|---|---|---|
| Activate the `project` cost allocation tag | `controlled_resources/disci/budget.tf` (the `disci-monthly` budget filters on `user:project$disci` and sees $0 until this is done) | AWS listing the tag (up to ~24h after resources tagged `project=disci` first bill; `project` was not listed on 2026-10-25) | `aws ce update-cost-allocation-tags-status --cost-allocation-tags-status TagKey=project,Status=Active --profile connor-ruff-dev-acct --region us-east-1`. Check `aws ce list-cost-allocation-tags --tag-keys project` first. Must run in the management account (`676058464455`). |
| Fill in the `disci-mcp-cognito-client-keys` secret value | Production MCP and the Disci settings page need the `disci-mcp` Cognito client ID/secret in one place. OpenTofu creates only the empty container (`general/secrets_manager/secret_disci_mcp_cognito_client_keys.tf`). | Connor | Secrets Manager console → `disci-mcp-cognito-client-keys` → Store a new secret value. Values: `tofu output mcp_client_id` and `tofu output -raw mcp_client_secret` in `controlled_resources/disci`. |
| Remove the test connector `disci-test` from claude.ai | The connector points at a stub and tunnel that no longer exist. | Connor | Customize → Connectors → `disci-test` → remove. |

## Done

Newest first. Format: date, what, where (console path or command), who, why.

- **2026-10-25: MCP connector auth test against Cognito.** Added `disci-mcp` Cognito client (`controlled_resources/disci/auth.tf`), ran a throwaway stub MCP server behind a `cloudflared` quick tunnel, and added it in claude.ai as a custom connector (Customize → Connectors → Add custom connector → Advanced settings → Use your own OAuth client, ID + secret from the `mcp_client_id` / `mcp_client_secret` outputs). Connor, to find out whether Claude's connector works with Cognito (no DCR, no advertised PKCE). Result: login, per-user `sub` and silent token refresh all work; Cognito kept. Stub and tunnel stopped. Findings: `disci` repo `docs/ops/deployment.md` §9. The access-token lifetime was temporarily 5 min for the refresh test and is back to 60.

## Known account settings that affect manual steps

- **IAM user and role access to Billing information is not activated** (seen 2026-10-25). The Billing console pages show an error for the SSO `AdministratorAccess` role, so the Cost allocation tags page looks empty. The `ce` CLI/API is not affected. Only root can turn it on: Account → IAM user and role access to Billing information → Edit → Activate.
- `676058464455` is the management account of Organization `o-8bzie2cvck`, so it is the account that can activate cost allocation tags.
