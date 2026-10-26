# Cognito user pool for the web app. Self-signup is off (invite-only): users are created
# here, the admin plus everyone in var.invited_emails. Each gets a temporary password by
# email and sets a real one on first sign-in through the hosted login page.

resource "aws_cognito_user_pool" "main" {
  name                     = local.name
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]
  deletion_protection      = "ACTIVE"

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  password_policy {
    minimum_length                   = 12
    require_lowercase                = true
    require_uppercase                = true
    require_numbers                  = true
    require_symbols                  = false
    temporary_password_validity_days = 7
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
}

resource "random_string" "cognito_domain_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Hosted login page: https://disci-<suffix>.auth.us-east-2.amazoncognito.com
resource "aws_cognito_user_pool_domain" "main" {
  domain       = "${local.name}-${random_string.cognito_domain_suffix.result}"
  user_pool_id = aws_cognito_user_pool.main.id
}

# Public client for the browser app: authorization code flow with PKCE, no secret.
resource "aws_cognito_user_pool_client" "web" {
  name         = "${local.name}-web"
  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret                      = false
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["openid", "email", "profile"]
  supported_identity_providers         = ["COGNITO"]
  callback_urls                        = ["${local.web_origin}/auth/callback"]
  logout_urls                          = ["${local.web_origin}/"]

  explicit_auth_flows           = ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
  prevent_user_existence_errors = "ENABLED"
  enable_token_revocation       = true

  id_token_validity      = 60
  access_token_validity  = 60
  refresh_token_validity = 30
  token_validity_units {
    id_token      = "minutes"
    access_token  = "minutes"
    refresh_token = "days"
  }
}

# Confidential client for Claude's custom connector (MCP). Cognito has no dynamic client
# registration, so the client ID and secret are entered by hand in the connector's
# Advanced settings. Claude's hosted apps always redirect to the callback below.
resource "aws_cognito_user_pool_client" "mcp" {
  name         = "${local.name}-mcp"
  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret                      = true
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["openid", "email", "profile"]
  supported_identity_providers         = ["COGNITO"]
  callback_urls                        = ["https://claude.ai/api/mcp/auth_callback"]

  explicit_auth_flows           = ["ALLOW_REFRESH_TOKEN_AUTH"]
  prevent_user_existence_errors = "ENABLED"
  enable_token_revocation       = true

  id_token_validity      = 60
  access_token_validity  = 60
  refresh_token_validity = 30
  token_validity_units {
    id_token      = "minutes"
    access_token  = "minutes"
    refresh_token = "days"
  }
}

resource "aws_cognito_user" "admin" {
  user_pool_id             = aws_cognito_user_pool.main.id
  username                 = var.admin_email
  desired_delivery_mediums = ["EMAIL"]

  attributes = {
    email          = var.admin_email
    email_verified = true
  }
}

# Invited users (testers, friends): same as the admin user, one per email.
resource "aws_cognito_user" "invited" {
  for_each = toset(var.invited_emails)

  user_pool_id             = aws_cognito_user_pool.main.id
  username                 = each.value
  desired_delivery_mediums = ["EMAIL"]

  attributes = {
    email          = each.value
    email_verified = true
  }
}
