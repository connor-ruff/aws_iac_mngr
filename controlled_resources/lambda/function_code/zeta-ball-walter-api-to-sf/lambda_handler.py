import json
from utils import *

# REFRESH_TYPE_ID values sent by STG.ZETA_BALL_WALTER_REFRESH_LAMBDA_TRIGGER
REFRESH_MATCHUPS = 1


def lambda_handler(event, context):

    # Snowflake external function body: {"data": [[row_number, arg1, arg2, ...]]}
    payload = json.loads(event["body"])["data"][0]
    refresh_type_id = payload[1]
    input_field_1, input_field_2, input_field_3, input_field_4, input_field_5 = payload[2:7]

    try:
        if refresh_type_id == REFRESH_MATCHUPS:
            # input_field_1 = season, input_field_2 = week
            result = refresh_matchups(input_field_1, input_field_2)
        else:
            raise ValueError(f'Unknown refresh_type_id: {refresh_type_id}')
    except Exception as e:
        print('Refresh failed:', e)
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }

    return {
        "statusCode": 200,
        "body": json.dumps({

            "data": [
               [0, result]
            ]
        })
    }
