# API Gateway Module

This module manages the REST API used by Snowflake external functions to invoke Lambda functions.

## Overview

Snowflake external functions work by calling an HTTP endpoint (API Gateway) which in turn invokes a Lambda. The `sf-external-function-role` IAM role (managed in the `iam/` module) is the trust bridge: Snowflake assumes that role, then uses it to call this API.

## Resources

**API:** `snowflake-ext-func-trigger` (id: `1dmrv6cveg`)
- Regional endpoint
- Resource policy restricts access to `sf-external-function-role` assumed by Snowflake

**Routes (both POST, AWS_IAM auth, Lambda proxy integration):**

| Path | Lambda target |
|---|---|
| `POST /lambda-ebird-general-refresher` | `lambda-ebird-general-refresher` |
| `POST /lambda-zeta-ball-refresh` | `lambda-zeta-ball-api-to-sf` |

**Stage:** `prod`

**Lambda permissions:** Two `aws_lambda_permission` resources grant API Gateway the right to invoke each Lambda. These are the resource-based policy statements on the Lambda side.

## File structure

| File | Contents |
|---|---|
| `main.tf` | S3 backend + AWS provider |
| `api.tf` | REST API, resources, methods, integrations, method responses, deployment, stage, and Lambda permissions |
| `imports.tf` | Import blocks for all 13 resources |
| `api_gateway.md` | This file |
