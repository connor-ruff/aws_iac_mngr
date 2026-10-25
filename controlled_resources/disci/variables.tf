# Personal values live in terraform.tfvars (gitignored; this repo is public).
# See terraform.tfvars.example.

variable "admin_email" {
  description = "Email for the first Cognito user (receives a temporary password) and budget alerts."
  type        = string
  sensitive   = true
}

variable "github_repo" {
  description = "owner/name of the app repo allowed to deploy via GitHub Actions."
  type        = string
  default     = "connor-ruff/disci"
}

variable "monthly_budget_usd" {
  description = "AWS Budgets alert threshold for resources tagged project=disci."
  type        = number
  default     = 25
}
