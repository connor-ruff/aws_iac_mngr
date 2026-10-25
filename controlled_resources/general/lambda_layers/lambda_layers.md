# Lambda Layers Module

This module manages the Lambda layer versions in Connor's AWS account.

## Layers

| Terraform resource | Layer name | Description | Compatible runtimes | Used by |
|---|---|---|---|---|
| `api_basic_layer` | `api-basic-layer:1` | requests, xmltodict | python3.10–3.14 | *(unattached)* |
| `google_api_python_client_layer` | `google-api-python-client-layer:2` | Google Drive API client | python3.8–3.10 (x86_64) | `lambda-gdrive-to-snowflake-pipe` |
| `pandas_layer` | `pandas-layer:2` | pandas and openpyxl | python3.8–3.10 (x86_64) | *(unattached)* |
| `snowflake_connector_python_3_13` | `snowflake-connector-python-3-13:2` | Snowflake connector | python3.13 | `lambda-zeta-ball-api-to-sf` |
| `snowflake_lambda_layer_from_youtube` | `snowflake-lambda-layer-from-youtube:1` | Snowflake connector (Python 3.8) | python3.8 (x86_64) | `lambda-gdrive-to-snowflake-pipe` |
| `zeta_ball_api_to_sf` | `zeta-ball-api-to-sf:1` | Zeta Ball API dependencies | python3.10–3.13 | `lambda-zeta-ball-api-to-sf`, `lambda-ebird-general-refresher` |

The AWS-managed layer `AWSSDKPandas-Python39:20` (account 336392948345) is not controlled here — it is owned by AWS and referenced by ARN directly in the lambda module.

## Notes on immutability

Layer versions are immutable — once published, a version's code can never change. Publishing new code always creates a new version number. OpenTofu manages this naturally: changing the zip triggers a new `aws_lambda_layer_version` resource (ForceNew), and you then update the ARN reference in the consuming function's `.tf` file.

All layers in this module were created manually before being imported. Their zip artifacts are not stored in this repo, so `lifecycle.ignore_changes` is used on `filename` and `source_code_hash` to prevent OpenTofu from detecting drift on the code itself.

The eventual goal is to manage layer source code in this repo (similar to how `lambda/function_code/` works for functions) so that publishing a new layer version is fully driven by OpenTofu. For now, layers are still built and uploaded manually.

## File structure

| File | Contents |
|---|---|
| `main.tf` | S3 backend, AWS provider, and shared `locals` |
| `layer_api_basic.tf` | `api_basic_layer` resource + import |
| `layer_google_api_python_client.tf` | `google_api_python_client_layer` resource + import |
| `layer_pandas.tf` | `pandas_layer` resource + import |
| `layer_snowflake_connector_python_3_13.tf` | `snowflake_connector_python_3_13` resource + import |
| `layer_snowflake_from_youtube.tf` | `snowflake_lambda_layer_from_youtube` resource + import |
| `layer_zeta_ball_api_to_sf.tf` | `zeta_ball_api_to_sf` resource + import |
| `placeholder.zip` | Dummy zip satisfying the `filename` requirement — never deployed |
