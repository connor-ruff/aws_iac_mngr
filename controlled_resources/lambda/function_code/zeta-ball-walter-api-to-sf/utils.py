import json
import urllib.error
import urllib.parse
import urllib.request

import boto3

BASE_URL = 'https://www.zetaball.com/api/v1'
LEAGUE_ID = 'zeta_ball'
SECRET_NAME = 'zetaball-walter-api-key'
BUCKET_NAME = 'connors-misc-blob-for-blobs'
S3_PREFIX = 'zeta_ball_walter'


def get_api_key():
    client = boto3.client('secretsmanager', region_name='us-east-2')
    secret_string = client.get_secret_value(SecretId=SECRET_NAME)['SecretString']
    try:
        return json.loads(secret_string)['api_key']
    except (json.JSONDecodeError, KeyError):
        return secret_string


def call_endpoint(api_key, path, params=None):
    """GET {BASE_URL}{path} and return the parsed JSON. Raises with error.fix/details on non-200."""
    url = BASE_URL + path
    if params:
        url += '?' + urllib.parse.urlencode(params)
    req = urllib.request.Request(
        url,
        headers={'Authorization': f'Bearer {api_key}', 'Accept': 'application/json'}
    )
    try:
        with urllib.request.urlopen(req, timeout=25) as resp:
            return json.loads(resp.read())
    except urllib.error.HTTPError as e:
        print('Error calling', path, e.code, e.read().decode())
        raise Exception(f'Failed to call {path}: {e.code}')


def drop_file_in_s3(data, file_key):
    s3_client = boto3.client('s3')
    s3_client.put_object(
        Body=json.dumps(data),
        Bucket=BUCKET_NAME,
        Key=file_key
    )
    print(f'File dropped in S3 at s3://{BUCKET_NAME}/{file_key}')


def refresh_matchups(season, week):
    """Pull one week of league matchups and drop the raw JSON in S3."""
    api_key = get_api_key()
    data = call_endpoint(
        api_key,
        f'/leagues/{LEAGUE_ID}/matchups',
        {'season': int(season), 'week': int(week)}
    )
    drop_file_in_s3(data, f'{S3_PREFIX}/matchups/season_{season}/week_{week}.json')
    return 'SUCCESS'
