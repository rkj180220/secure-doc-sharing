import boto3
import json
import os
from datetime import datetime
from base64 import b64decode
from decimal import Decimal
from boto3.dynamodb.conditions import Key

s3_client = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])

class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return float(obj)
        return super(DecimalEncoder, self).default(obj)

def lambda_handler(event, context):
    if 'Records' in event and event['Records'][0]['eventSource'] == 'aws:s3':
        print(f"S3 event detected {event}")
        return handle_s3_event(event)

    path = event['path']
    http_method = event['httpMethod']
    print(f"event: {event}")
    print(f"HTTP method: {http_method}")
    print(f"Path: {path}")

    if path == '/file':
        if http_method == 'POST':
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
    elif path == '/file/presignedURL':
        if http_method == 'POST':
            return get_pre_signed_url(event)
        else:
            return {
                'statusCode': 400,
                'body': json.dumps('Invalid HTTP method')
            }
    else:
        return {
            'statusCode': 404,
            'body': json.dumps('Path not found')
        }


def handle_s3_event(event):
    for record in event['Records']:
        bucket_name = record['s3']['bucket']['name']
        s3_key = record['s3']['object']['key']
        file_size = record['s3']['object']['size']

        # Extract user_id and file_name from the S3 key
        user_id, file_name_with_timestamp = s3_key.split('/', 1)
        file_name, timestamp_with_extension = file_name_with_timestamp.rsplit('_', 1)
        timestamp, file_extension = timestamp_with_extension.rsplit('.', 1)

        # Update metadata in DynamoDB
        response = table.update_item(
            Key={
                'FileID': s3_key,  # Ensure this matches the primary key schema
                'UserID': user_id  # Add this if your table has a composite primary key
            },
            UpdateExpression="SET FileSize = :fs, UploadStatus = :us, updated_at = :ua",
            ExpressionAttributeValues={
                ':fs': file_size,
                ':us': 'COMPLETED',
                ':ua': str(datetime.utcnow())
            },
            ReturnValues="UPDATED_NEW"
        )

        if response['ResponseMetadata']['HTTPStatusCode'] != 200:
            return {
                'statusCode': 500,
                'body': json.dumps(f"Failed to update metadata for file {s3_key}")
            }

    return {
        'statusCode': 200,
        'body': json.dumps("Metadata updated successfully for all files")
    }

def get_pre_signed_url(event):
    body = json.loads(event['body'])
    file_name = body['fileName'].replace(' ', '_')  # Replace spaces with underscores
    file_type = file_name.split('.')[-1]
    user_id = body['userId']
    timestamp = datetime.utcnow().strftime('%Y%m%d%H%M%S')
    file_name_with_timestamp = f"{file_name.rsplit('.', 1)[0]}_{timestamp}.{file_type}"
    s3_key = f"{user_id}/{file_name_with_timestamp}"

    # Generate presigned URL for file upload
    pre_signed_url = s3_client.generate_presigned_url(
        'put_object',
        Params={
            'Bucket': os.environ['S3_BUCKET'],
            'Key': s3_key,
            'ContentType': body['fileType']
        },
        ExpiresIn=3600  # URL expiration time in seconds
    )

    # Store metadata in DynamoDB
    table.put_item(
        Item={
            'FileID': s3_key,  # S3 file path
            'UserID': user_id,  # Owner of the file
            'FileType': body['fileType'],  # e.g., .pdf, .jpg
            'FileSize': 0,  # Size will be updated later
            'created_at': timestamp,  # Timestamp of the upload request
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
    body = json.loads(event['body'])
    user_id = body['userId']

    # Query files by user from DynamoDB
    response = table.query(
        IndexName='UserID-index',  # Ensure you have a secondary index on UserID
        KeyConditionExpression=Key('UserID').eq(user_id)
    )

    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Origin': 'http://localhost:5173',
            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
            'Access-Control-Allow-Methods': 'OPTIONS,POST',
        },
        'body': json.dumps(response['Items'], cls=DecimalEncoder)
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
