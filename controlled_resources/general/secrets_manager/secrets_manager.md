# Secrets Manager Module

This module manages the Secrets Manager secret containers in Connor's AWS account.

## Secrets

| Terraform resource | Secret name | Description |
|---|---|---|
| `personal_google_drive_service_acct` | `Personal-Google-Drive-Service_acct` | GCP service account key for Personal-Drive-API project |
| `snowflake_prog_user` | `snowflake-PROG_USER` | Snowflake PROG_USER service account credentials (RSA keys) |
| `yahoo_fantasy_slop_api_keys` | `yahoo-fantasy--slop-api-keys` | Yahoo Fantasy API credentials for Zeta Ball basketball league |
| `ebird_api_credentials` | `eBird-api-credentials` | eBird API credentials for account connorruff |
| `zetaball_walter_api_key` | `zetaball-walter-api-key` | API key for the League Data API v1 on Walter's zetaball.com |
| `disci_mcp_cognito_client_keys` | `disci-mcp-cognito-client-keys` | Client ID and secret of the Disci `disci-mcp` Cognito app client (Claude custom connector); tagged `project=disci` |

## What is and isn't managed

OpenTofu manages the **secret container** — the name, description, and metadata. It does **not** manage the secret value/version. Secret values are set and rotated manually; they are never stored in this repo or in OpenTofu state.

## File structure

| File | Contents |
|---|---|
| `main.tf` | S3 backend + AWS provider |
| `secret_personal_google_drive_service_acct.tf` | `personal_google_drive_service_acct` secret + import |
| `secret_snowflake_prog_user.tf` | `snowflake_prog_user` secret + import |
| `secret_yahoo_fantasy_slop_api_keys.tf` | `yahoo_fantasy_slop_api_keys` secret + import |
| `secret_ebird_api_credentials.tf` | `ebird_api_credentials` secret + import |
| `secret_zetaball_walter_api_key.tf` | `zetaball_walter_api_key` secret (new, no import) |
| `secret_disci_mcp_cognito_client_keys.tf` | `disci_mcp_cognito_client_keys` secret (new, no import) |
| `secrets_manager.md` | This file |
