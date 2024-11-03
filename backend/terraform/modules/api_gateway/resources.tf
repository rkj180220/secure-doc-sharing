# upload file
resource "aws_api_gateway_resource" "file" {
  rest_api_id = aws_api_gateway_rest_api.doc_api.id
  parent_id   = aws_api_gateway_rest_api.doc_api.root_resource_id
  path_part   = "file"
}

# Get Presigned URL
resource "aws_api_gateway_resource" "presigned_url" {
  rest_api_id = aws_api_gateway_rest_api.doc_api.id
  parent_id   = aws_api_gateway_resource.file.id
  path_part   = "presignedURL"
}

# List Cognito Users
resource "aws_api_gateway_resource" "list_cognito_users" {
  rest_api_id = aws_api_gateway_rest_api.doc_api.id
  parent_id   = aws_api_gateway_rest_api.doc_api.root_resource_id
  path_part   = "listCognitoUsers"
}

# upload file
resource "aws_api_gateway_resource" "share_file" {
  rest_api_id = aws_api_gateway_rest_api.doc_api.id
  parent_id   = aws_api_gateway_rest_api.doc_api.root_resource_id
  path_part   = "shareFile"
}
