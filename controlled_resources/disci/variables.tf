# Personal values live in terraform.tfvars (gitignored; this repo is public).
# See terraform.tfvars.example.

variable "admin_email" {
  description = "Email for the first Cognito user (receives a temporary password) and budget alerts."
  type        = string
  sensitive   = true
}

variable "invited_emails" {
  description = <<-EOT
    Extra people who may sign in (self-signup is off). Each gets a Cognito user and an
    emailed temporary password. Set in terraform.tfvars; removing an email deletes that
    user from Cognito (their app data stays in the database).
  EOT
  type        = list(string)
  default     = []
  # Not `sensitive`: OpenTofu can't for_each over sensitive values. The list still only
  # lives in the gitignored terraform.tfvars.
}

variable "github_repo" {
  description = <<-EOT
    App repo allowed to deploy via GitHub Actions, as it appears in GitHub's OIDC `sub`
    claim: <owner>@<owner_id>/<repo>@<repo_id>. GitHub includes the immutable numeric IDs,
    so a deleted-and-recreated repo with the same name can't assume the role.
  EOT
  type        = string
  default     = "connor-ruff@58089177/disci@1432836715"
}

variable "monthly_budget_usd" {
  description = "AWS Budgets alert threshold for resources tagged project=disci."
  type        = number
  default     = 25
}
