terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "connor-ruff-terraform-state"
    key            = "api_gateway/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-state-lock"
    profile        = "connor-ruff-dev-acct"
  }
}

provider "aws" {
  region  = "us-east-2"
  profile = "connor-ruff-dev-acct"
}

locals {
  account_id = "676058464455"
  region     = "us-east-2"
  api_id     = "1dmrv6cveg"
}
