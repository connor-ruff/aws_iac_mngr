import boto3
import pandas as pd
import io

s3 = boto3.client("s3")


def lambda_handler(event, context):
    source_bucket = event["source_bucket"]
    source_key = event["source_key"]
    sheet_name = event["sheet_name"]
    dest_bucket = event["dest_bucket"]
    dest_key = event["dest_key"]
    move_after_operation = event.get("move_after_operation", False)

    response = s3.get_object(Bucket=source_bucket, Key=source_key)
    excel_bytes = response["Body"].read()

    df = pd.read_excel(io.BytesIO(excel_bytes), sheet_name=sheet_name)

    csv_buffer = io.StringIO()
    df.to_csv(csv_buffer, index=False, encoding="utf-8")

    s3.put_object(
        Bucket=dest_bucket,
        Key=dest_key,
        Body=csv_buffer.getvalue().encode("utf-8"),
        ContentType="text/csv; charset=utf-8",
    )

    if move_after_operation:
        filename = source_key.split("/")[-1]
        folder = "/".join(source_key.split("/")[:-1])
        processed_key = f"{folder}/processed/{filename}"
        s3.copy_object(
            Bucket=source_bucket,
            CopySource={"Bucket": source_bucket, "Key": source_key},
            Key=processed_key,
        )
        s3.delete_object(Bucket=source_bucket, Key=source_key)

    return {
        "statusCode": 200,
        "body": f"Converted s3://{source_bucket}/{source_key} sheet '{sheet_name}' → s3://{dest_bucket}/{dest_key}",
    }
