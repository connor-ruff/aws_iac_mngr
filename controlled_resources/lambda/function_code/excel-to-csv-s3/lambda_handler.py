import boto3
import pandas as pd
import io
import os

s3 = boto3.client("s3")


def _convert_and_upload(source_bucket, source_key, sheet_name, dest_bucket, dest_folder):
    response = s3.get_object(Bucket=source_bucket, Key=source_key)
    excel_bytes = response["Body"].read()

    df = pd.read_excel(io.BytesIO(excel_bytes), sheet_name=sheet_name)

    csv_buffer = io.StringIO()
    df.to_csv(csv_buffer, index=False, encoding="utf-8")

    excel_base = os.path.splitext(source_key.split("/")[-1])[0]
    dest_folder = dest_folder if dest_folder.endswith("/") else dest_folder + "/"
    sheet_folder = sheet_name.lower().replace(" ", "_")
    dest_key = f"{dest_folder}{sheet_folder}/{excel_base}-{sheet_folder}.csv"

    s3.put_object(
        Bucket=dest_bucket,
        Key=dest_key,
        Body=csv_buffer.getvalue().encode("utf-8"),
        ContentType="text/csv; charset=utf-8",
    )

    return dest_key


def _move_to_processed(source_bucket, source_key):
    filename = source_key.split("/")[-1]
    folder = "/".join(source_key.split("/")[:-1])
    processed_key = f"{folder}/processed/{filename}"
    s3.copy_object(
        Bucket=source_bucket,
        CopySource={"Bucket": source_bucket, "Key": source_key},
        Key=processed_key,
    )
    s3.delete_object(Bucket=source_bucket, Key=source_key)


def _process_file(source_bucket, source_key, sheet_names, dest_bucket, dest_folder, move_after_operation):
    converted = []
    for sheet_name in sheet_names:
        dest_key = _convert_and_upload(source_bucket, source_key, sheet_name, dest_bucket, dest_folder)
        converted.append(dest_key)
    if move_after_operation:
        _move_to_processed(source_bucket, source_key)
    return converted


def lambda_handler(event, context):
    source_bucket = event["source_bucket"]
    source_key = event["source_key"]
    sheet_names = [s.strip() for s in event["sheet_names"].split(",")]
    dest_bucket = event["dest_bucket"]
    dest_folder = event["dest_folder"]
    processing_type = event["processing_type"]
    move_after_operation = event.get("move_after_operation", False)

    if processing_type == "single-file":
        converted = _process_file(source_bucket, source_key, sheet_names, dest_bucket, dest_folder, move_after_operation)
        return {
            "statusCode": 200,
            "body": f"Converted s3://{source_bucket}/{source_key} sheets {sheet_names} → {converted}",
        }

    elif processing_type == "whole-folder":
        prefix = source_key if source_key.endswith("/") else source_key + "/"

        response = s3.list_objects_v2(Bucket=source_bucket, Prefix=prefix, Delimiter="/")
        files = [obj["Key"] for obj in response.get("Contents", []) if not obj["Key"].endswith("/")]

        converted = []
        for file_key in files:
            converted.extend(_process_file(source_bucket, file_key, sheet_names, dest_bucket, dest_folder, move_after_operation))

        return {
            "statusCode": 200,
            "body": f"Converted {len(files)} files ({len(sheet_names)} sheets each) from s3://{source_bucket}/{prefix} → {converted}",
        }

    else:
        raise ValueError(f"Unknown processing_type '{processing_type}': must be 'single-file' or 'whole-folder'.")
