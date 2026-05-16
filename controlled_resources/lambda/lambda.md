# Lambda Module

This module manages the Lambda functions in Connor's AWS account.

## Functions

| Terraform resource | Function name | Purpose | Runtime | Timeout |
|---|---|---|---|---|
| `gdrive_to_snowflake_pipe` | `lambda-gdrive-to-snowflake-pipe` | Reads files from Google Drive and loads them to Snowflake. Invokes the Excel→CSV helper as a sub-step. | Python 3.8 | 5 min |
| `zeta_ball_api_to_sf` | `lambda-zeta-ball-api-to-sf` | Pulls data from the Zeta Ball (Yahoo Fantasy) API and loads it to Snowflake. | Python 3.13 | ~4 min |
| `ebird_general_refresher` | `lambda-ebird-general-refresher` | Pulls bird sighting data from the eBird API and writes it to S3. | Python 3.13 | ~10 min |
| `convert_excel_bytes_to_csv` | `lambda-convert-excel-bytes-to-csv` | Helper function: accepts Excel bytes and returns CSV. Called by the GDrive pipeline. | Python 3.9 | 1 min |

## Layers

Lambda layers are managed in the dedicated `controlled_resources/lambda_layers/` module. Their ARNs are referenced directly as string literals in each function's `.tf` file here.

| Layer ARN | Used by |
|---|---|
| `google-api-python-client-layer:2` | gdrive_to_snowflake_pipe |
| `snowflake-lambda-layer-from-youtube:1` | gdrive_to_snowflake_pipe |
| `zeta-ball-api-to-sf:1` | zeta_ball_api_to_sf, ebird_general_refresher |
| `snowflake-connector-python-3-13:2` | zeta_ball_api_to_sf |
| `AWSSDKPandas-Python39:20` (AWS-managed, account 336392948345) | convert_excel_bytes_to_csv |

## Code deployment

Functions whose source code lives in `function_code/` are managed by OpenTofu end-to-end. OpenTofu tracks the zip hash — when the hash changes, `tofu apply` redeploys the code automatically.

To deploy updated code for these functions:

```bash
cd function_code/<function-name>/
bash build-lambda-zip.sh   # rebuilds lambda-package.zip from source
cd ../../
tofu apply                 # deploys if hash changed, no-op if unchanged
```

Functions **not yet in `function_code/`** (`lambda-gdrive-to-snowflake-pipe` and `lambda-convert-excel-bytes-to-csv`) still use `placeholder.zip` with `lifecycle.ignore_changes` — OpenTofu manages their configuration but not their code. Deploy those manually:

```bash
aws lambda update-function-code \
  --function-name <function-name> \
  --zip-file fileb://your-package.zip \
  --profile connor-ruff-dev-acct
```

## File structure

Each Lambda function has its own `.tf` file containing the `aws_lambda_function` resource and its import block. Everything about a function is in one place.

| File/Folder | Contents |
|---|---|
| `main.tf` | S3 backend, AWS provider, and shared `locals` |
| `lambda_gdrive_to_snowflake_pipe.tf` | `gdrive_to_snowflake_pipe` function + import |
| `lambda_zeta_ball_api_to_sf.tf` | `zeta_ball_api_to_sf` function + import |
| `lambda_ebird_general_refresher.tf` | `ebird_general_refresher` function + import |
| `lambda_convert_excel_bytes_to_csv.tf` | `convert_excel_bytes_to_csv` function + import |
| `placeholder.zip` | Dummy zip satisfying the code source requirement — never deployed |
| `function_code/zeta-ball-api-to-sf/` | Source code + build script for `lambda-zeta-ball-api-to-sf` |
| `function_code/ebird-general-refresher/` | Source code + build script for `lambda-ebird-general-refresher` |
