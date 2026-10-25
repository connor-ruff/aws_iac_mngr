terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100"
    }
  }

  backend "s3" {
    bucket         = "connor-ruff-terraform-state"
    key            = "admin/github_oidc/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-state-lock"
    profile        = "connor-ruff-dev-acct"
  }
}

provider "aws" {
  region  = "us-east-2"
  profile = "connor-ruff-dev-acct"
}

# Lets GitHub Actions workflows assume IAM roles without stored AWS keys.
# One per account; each project defines its own role trusting this provider
# (e.g. controlled_resources/disci/ci.tf).
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  # AWS validates GitHub's certificate via its own trusted CAs; these are GitHub's
  # published intermediate thumbprints, kept because the API still accepts the field.
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd",
  ]
}

output "github_oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.github.arn
}
