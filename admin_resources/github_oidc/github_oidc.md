# GitHub OIDC provider

Account-wide IAM OIDC identity provider for GitHub Actions (`token.actions.githubusercontent.com`). It lets workflows assume IAM roles with short-lived credentials instead of stored access keys.

AWS allows only one provider per URL per account, so it lives here (admin, one-time) rather than in a project. Each project creates its own role that trusts this provider and restricts which repo/branch may assume it. Example: `controlled_resources/disci/ci.tf` (only `connor-ruff/disci` on `main`).

## How to apply

```bash
cd admin_resources/github_oidc/
tofu init
tofu plan
tofu apply
```

Apply this **before** any project that references it (projects reference its ARN in their deploy role trust policies).
