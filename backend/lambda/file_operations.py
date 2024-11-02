import boto3
import json
import os
from datetime import datetime
from base64 import b64decode

s3_client = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])


def lambda_handler(event, context):
    http_method = event['httpMethod']
    print(f"event: {event}")
    print(f"HTTP method: {http_method}")

    if http_method == 'POST':
        return get_pre_signed_url(event)
    elif http_method == 'GET':
        return list_files(event)
    elif http_method == 'DELETE':
        return delete_file(event)
    elif http_method == 'PUT':
        return update_file(event)
    else:
        return {
            'statusCode': 400,
            'body': json.dumps('Invalid HTTP method')
        }


def get_pre_signed_url(event):
    body = json.loads(event['body'])
    file_name = body['fileName']
    file_type = body['fileType']
    user_id = body['userId']

    # Generate presigned URL for file upload
    pre_signed_url = s3_client.generate_presigned_url(
        'put_object',
        Params={
            'Bucket': os.environ['S3_BUCKET'],
            'Key': file_name,
            'ContentType': file_type
        },
        ExpiresIn=3600  # URL expiration time in seconds
    )

    # Store metadata in DynamoDB
    table.put_item(
        Item={
            'FileID': file_name,  # S3 file path
            'UserID': user_id,  # Owner of the file
            'FileType': file_type,  # e.g., .pdf, .jpg
            'FileSize': 0,  # Size will be updated later
            'Timestamp': str(datetime.utcnow()),  # Timestamp of the upload request
            'UploadStatus': 'PENDING'  # Initial status
        }
    )

    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Origin': 'http://localhost:5173',
            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
            'Access-Control-Allow-Methods': 'OPTIONS,POST',
        },
        'body': json.dumps({
            'message': f"Presigned URL generated for {file_name}",
            'pre_signedUrl': pre_signed_url
        }),
    }

def update_file_metadata(event):
    body = json.loads(event['body'])
    file_name = body['fileName']
    file_size = body['fileSize']

    # Update metadata in DynamoDB
    response = table.update_item(
        Key={
            'FileID': file_name
        },
        UpdateExpression="SET FileSize = :fs, UploadStatus = :us, Timestamp = :ts",
        ExpressionAttributeValues={
            ':fs': file_size,
            ':us': 'COMPLETED',
            ':ts': str(datetime.utcnow())
        },
        ReturnValues="UPDATED_NEW"
    )

    if response['ResponseMetadata']['HTTPStatusCode'] == 200:
        return {
            'statusCode': 200,
            'body': json.dumps(f"File {file_name} metadata updated successfully")
        }
    else:
        return {
            'statusCode': 500,
            'body': json.dumps(f"Failed to update metadata for file {file_name}")
        }

def list_files(event):
    user_id = event['queryStringParameters']['userId']

    # Query files by user from DynamoDB
    response = table.query(
        KeyConditionExpression=Key('UserID').eq(user_id)
    )

    return {
        'statusCode': 200,
        'body': json.dumps(response['Items'])
    }

def delete_file(event):
    body = json.loads(event['body'])
    file_name = body['fileName']

    # Delete from S3
    s3_client.delete_object(
        Bucket=os.environ['S3_BUCKET'],
        Key=file_name
    )

    # Delete metadata from DynamoDB
    table.delete_item(
        Key={
            'FileID': file_name
        }
    )

    return {
        'statusCode': 200,
        'body': json.dumps(f"File {file_name} deleted successfully")
    }


def update_file(event):
    body = json.loads(event['body'])
    file_content = b64decode(body['file'])
    file_name = body['fileName']
    file_type = body['fileType']

    # Update file in S3
    s3_client.put_object(
        Bucket=os.environ['S3_BUCKET'],
        Key=file_name,
        Body=file_content,
        ContentType=file_type
    )

    # Optionally update metadata in DynamoDB (e.g., update timestamp)
    table.update_item(
        Key={
            'FileID': file_name
        },
        UpdateExpression="SET #ts = :t",
        ExpressionAttributeNames={
            "#ts": "Timestamp"
        },
        ExpressionAttributeValues={
            ":t": str(datetime.utcnow())
        }
    )

    return {
        'statusCode': 200,
        'body': json.dumps(f"File {file_name} updated successfully")
    }
