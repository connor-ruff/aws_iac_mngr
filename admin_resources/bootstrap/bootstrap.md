# Bootstrap

This `bootstrap` is a one-time setup that creates the infrastructure Terraform needs to manage state for all other modules in this repo. Run it once when setting up the account, then leave it alone.

## Purpose

Terraform tracks what it has created via a state file. Without a remote backend, that state file lives locally and is easy to lose or corrupt. This bootstrap creates an S3 bucket to store state remotely, plus a DynamoDB table to prevent concurrent `apply` runs from corrupting state.

All other modules in this repo (`iam/`, `s3/`, etc.) use the resources created here as their backend.

## How to run

```bash
aws sso login --profile connor-ruff-dev-acct
cd bootstrap
tofu init
tofu plan
tofu apply
```

## Resources created

### S3 Bucket — `connor-ruff-terraform-state`
Stores the `.tfstate` files for every module in this repo. Each module gets its own state file at a separate key within this bucket.

- **Versioning enabled** — allows recovery if state is accidentally corrupted or deleted
- **AES256 encryption** — state files can contain sensitive values (ARNs, IDs, occasionally secrets), so they are encrypted at rest
- **Public access fully blocked** — no public ACLs or policies are permitted

### DynamoDB Table — `terraform-state-lock`
Provides state locking. When a `tofu apply` is in progress, it writes a lock entry to this table. Any other `apply` that runs concurrently will see the lock and abort rather than risk corrupting state.

- **Billing mode: PAY_PER_REQUEST** — only charged per lock/unlock operation, effectively free for personal use
- **Hash key: `LockID`** — required field used by the Terraform S3 backend
