# IAM Identity Center

> **This is not managed in Terraform.** IAM Identity Center is configured manually via the AWS console. See the bottom of this page for why.

## What it is

IAM Identity Center (formerly AWS SSO) is the modern AWS approach to human identity management. Instead of creating traditional IAM users with long-lived access keys, you have a single identity that you use to log in and temporarily assume roles into AWS accounts.

Think of it as the front door to your AWS account — you authenticate once, then step into whatever role you need.

## How the login flow works

1. You run `aws sso login --profile connor-ruff-dev-acct` (or open the access portal in the browser)
2. You're prompted for a username, password, and Okta 2FA code — this is authenticating with **Okta**, not AWS directly. IAM Identity Center is configured to trust Okta as an external identity provider, so your identity lives in Okta, not in AWS.
3. Okta verifies your credentials and tells IAM Identity Center "this person is who they say they are"
4. You select an account and permission set from the portal
5. IAM Identity Center issues you **temporary credentials** by assuming the corresponding IAM role on your behalf
6. Those credentials expire (max 12 hours) and you re-authenticate

The full chain looks like:
```
Okta (identity) → IAM Identity Center (bridge) → AWS IAM Role (actual permissions)
```

There are no long-lived access keys involved anywhere in this flow. This is why there are no traditional IAM users in this account — you don't need them.

## What is connor-ruff-dev-acct?

`connor-ruff-dev-acct` is your Okta username. When the access portal prompts you to log in, you're entering Okta credentials — AWS never directly handles your password. `connorruff` is the display name Okta passes to AWS for that identity once authenticated.

## Your setup

| Property | Value |
|---|---|
| SSO Instance ARN | `arn:aws:sso:::instance/ssoins-7223616b5f3428f9` |
| Identity Store ID | `d-9067f8510b` |
| Home region | `us-east-1` |
| Owner account | `676058464455` |
| Okta username | `connor-ruff-dev-acct` |
| Display name in portal | `connorruff` |

IAM Identity Center is a global service but is anchored to a home region. Yours is in `us-east-1`.

## The role it creates

When IAM Identity Center sets up a permission set, it creates a corresponding IAM role in your account with a reserved name:

```
AWSReservedSSO_AdministratorAccess_2bd1c44312e4d1f6
```

This role is what actually gets assumed when you log in with the `AdministratorAccess` permission set. It is managed entirely by IAM Identity Center — do not modify or delete it manually, and do not import it into Terraform.

## Your AWS CLI profile

Your local `~/.aws/config` has a profile named `connor-ruff-dev-acct` that points at this SSO setup. When you run any AWS CLI or Terraform command with `--profile connor-ruff-dev-acct`, it uses the temporary credentials issued by this SSO session.

## Why this isn't managed in Terraform

Terraform can manage IAM Identity Center resources via `aws_ssoadmin_*` resources, but for this account it isn't worth it:

- **Lock-out risk** — a bad `tofu apply` against your only admin identity could lock you out of your own account with no easy recovery path
- **It's already correct** — one user, one permission set, working fine. There's nothing to improve.
- **Low churn** — this configuration almost never changes. IaC is most valuable for things that change frequently or need to be recreated.

If the setup ever becomes more complex (multiple users, multiple permission sets, multiple accounts), it would be worth revisiting.
