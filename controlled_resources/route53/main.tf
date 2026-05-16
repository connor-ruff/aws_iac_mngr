terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "connor-ruff-terraform-state"
    key            = "route53/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-state-lock"
    profile        = "connor-ruff-dev-acct"
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "connor-ruff-dev-acct"
}
