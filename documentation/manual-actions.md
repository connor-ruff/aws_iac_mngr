# Manual actions

Things that have to be done by hand (console clicks, root-only settings, account-level toggles, or CLI calls that change settings OpenTofu doesn't manage). Anything here is **not** reproduced by `tofu apply`, so a rebuilt or new account needs these repeated.

`aws` CLI commands are also logged in `aws-cli-commands/`; link the log file from the entry when one exists.

## Pending

| Action | Needed by | Blocked on | How |
|---|---|---|---|
| _(none)_ | | | |

## Done

Newest first. Format: date, what, where (console path or command), who, why.

- **2026-10-26: Cleanup after the MCP test.** Connor filled in the `disci-mcp-cognito-client-keys` secret value (Secrets Manager console) and removed the `disci-test` custom connector from claude.ai.
- **2026-10-26: Activated the `project` cost allocation tag.** Connor, in the Billing console (Cost allocation tags → `project` → Activate); Active as of 2026-10-26T16:01Z (log: `aws-cli-commands/2026-10-26_12-03-48_list-cost-allocation-tags-project-active.md`). Makes the `disci-monthly` budget filter (`user:project$disci`) match. Spend still read $0 right after activation; AWS applies the tag to cost data after a delay and does not backfill, so re-check the budget later.
- **2026-10-25: MCP connector auth test against Cognito.** Added `disci-mcp` Cognito client (`controlled_resources/disci/auth.tf`), ran a throwaway stub MCP server behind a `cloudflared` quick tunnel, and added it in claude.ai as a custom connector (Customize → Connectors → Add custom connector → Advanced settings → Use your own OAuth client, ID + secret from the `mcp_client_id` / `mcp_client_secret` outputs). Connor, to find out whether Claude's connector works with Cognito (no DCR, no advertised PKCE). Result: login, per-user `sub` and silent token refresh all work; Cognito kept. Stub and tunnel stopped. Findings: `disci` repo `docs/ops/deployment.md` §9. The access-token lifetime was temporarily 5 min for the refresh test and is back to 60.

## Known account settings that affect manual steps

- **IAM user and role access to Billing information is not activated** (seen 2026-10-25). The Billing console pages show an error for the SSO `AdministratorAccess` role, so the Cost allocation tags page looks empty. The `ce` CLI/API is not affected. Only root can turn it on: Account → IAM user and role access to Billing information → Edit → Activate.
- `676058464455` is the management account of Organization `o-8bzie2cvck`, so it is the account that can activate cost allocation tags.
