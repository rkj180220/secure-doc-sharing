import boto3
import json
import os

cognito_client = boto3.client('cognito-idp')

def lambda_handler(event, context):
    user_pool_id = os.environ['COGNITO_USER_POOL_ID']

    response = cognito_client.list_users(
        UserPoolId=user_pool_id
    )

    users = []
    for user in response['Users']:
        user_info = {
            'user_id': user['Username'],
            'username': next((attr['Value'] for attr in user['Attributes'] if attr['Name'] == 'preferred_username'), None),
            'email': next((attr['Value'] for attr in user['Attributes'] if attr['Name'] == 'email'), None)
        }
        users.append(user_info)

    return {
        'statusCode': 200,
        'body': json.dumps(users),
        'headers': {
            'Access-Control-Allow-Origin': 'http://localhost:5173',
            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
            'Access-Control-Allow-Methods': 'GET,OPTIONS'
        }
    }