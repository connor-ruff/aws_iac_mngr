terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.7"
    }
  }

  backend "s3" {
    bucket         = "connor-ruff-terraform-state"
    key            = "disci/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-state-lock"
    profile        = "connor-ruff-dev-acct"
  }
}

provider "aws" {
  region  = "us-east-2"
  profile = "connor-ruff-dev-acct"

  default_tags {
    tags = {
      project    = "disci"
      managed_by = "opentofu"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  name       = "disci"
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  web_origin = "https://${aws_cloudfront_distribution.web.domain_name}"
}
