import json 
from utils import *

def lambda_handler(event, context):
    
    switch_value = json.loads(event["body"])["data"][0][1]
    if switch_value == "REFRESH_GEO_REGIONS":
        refresh_geo_regions(event)
    elif switch_value == "REFRESH_TAXONOMY_REF":
        refresh_taxonomy_ref(event)
    else:
        raise ValueError(f"Unknown switch value: {switch_value}")

    return {
        "statusCode": 200,
        "body": json.dumps({

            "data": [
               [0, "SUCCESS"]
            ]
        })
    }