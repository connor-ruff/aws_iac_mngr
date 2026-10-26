# AWS Manager — Claude Instructions

This repo is meant to manage the personal AWS account of Connor Ruff via IaC

## Active Skills

**aws-cli-skill** (always active): Whenever you run any `aws ...` CLI command, log the command and its full output to a new file in `aws-cli-commands/` before doing anything else. See `.claude/skills/aws-cli-skill.md` for the exact format and naming rules.

**manual actions log** (always active): Anything done by hand that OpenTofu does not manage (console clicks, root-only account settings, `aws` calls that change settings) must be recorded in `documentation/manual-actions.md`: add it under "Pending" when identified, and move it to "Done" (with date and how) once completed. Also note it in the relevant root's doc (e.g. `controlled_resources/disci/disci.md`). `aws` commands are additionally logged per the skill above.

## Project context

- OpenTofu (not Terraform) for IaC
- AWS profile: `connor-ruff-dev-acct` (SSO via IAM Identity Center)
- Primary region: `us-east-2`, secondary `us-east-1`
- State bucket: `connor-ruff-terraform-state` | Lock table: `terraform-state-lock`
- `bootstrap/` is complete — do not re-run it

## Repo layout

```
admin_resources/            # one-time, account-level setup (state backend, Identity Center, GitHub OIDC)
controlled_resources/
├── general/                # everything not owned by a dedicated project; one root (and state) per AWS service
└── disci/                  # the Disci app (github: disci repo); one root, one state: disci/terraform.tfstate
```

- Each root's state key is hardcoded in its `main.tf` backend block, so moving a folder does **not** move its state. After moving a root, run `tofu init` + `tofu plan` and expect "No changes".
- New project-specific infra gets its own folder under `controlled_resources/`. Anything else goes in `general/`.
