# AWS Manager — Claude Instructions

This repo is meant to manage the personal AWS account of Connor Ruff via IaC

## Active Skills

**aws-cli-skill** (always active): Whenever you run any `aws ...` CLI command, log the command and its full output to a new file in `aws-cli-commands/` before doing anything else. See `.claude/skills/aws-cli-skill.md` for the exact format and naming rules.

## Project context

- OpenTofu (not Terraform) for IaC
- AWS profile: `connor-ruff-dev-acct` (SSO via IAM Identity Center)
- Primary region: `us-east-2`, secondary `us-east-1`
- State bucket: `connor-ruff-terraform-state` | Lock table: `terraform-state-lock`
- `bootstrap/` is complete — do not re-run it
