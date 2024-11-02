resource "aws_api_gateway_method" "upload_file" {
  rest_api_id   = aws_api_gateway_rest_api.doc_api.id
  resource_id   = aws_api_gateway_resource.file.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}

resource "aws_api_gateway_method" "get_presigned_url" {
  rest_api_id   = aws_api_gateway_rest_api.doc_api.id
  resource_id   = aws_api_gateway_resource.presigned_url.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}

# To Handle CORS, need to have the options method for upload file
resource "aws_api_gateway_method" "options_upload_file" {
  rest_api_id   = aws_api_gateway_rest_api.doc_api.id
  resource_id   = aws_api_gateway_resource.file.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_upload_file" {
  rest_api_id             = aws_api_gateway_rest_api.doc_api.id
  resource_id             = aws_api_gateway_resource.file.id
  http_method             = aws_api_gateway_method.options_upload_file.http_method
  type                    = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_upload_file" {
  rest_api_id = aws_api_gateway_rest_api.doc_api.id
  resource_id = aws_api_gateway_resource.file.id
  http_method = aws_api_gateway_method.options_upload_file.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options_upload_file" {
  rest_api_id = aws_api_gateway_rest_api.doc_api.id
  resource_id = aws_api_gateway_resource.file.id
  http_method = aws_api_gateway_method.options_upload_file.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'http://localhost'"
  }

  response_templates = {
    "application/json" = ""
  }
}


resource "aws_api_gateway_method_response" "post_upload_file" {
  rest_api_id = aws_api_gateway_rest_api.doc_api.id
  resource_id = aws_api_gateway_resource.file.id
  http_method = aws_api_gateway_method.upload_file.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "post_upload_file" {
  rest_api_id = aws_api_gateway_rest_api.doc_api.id
  resource_id = aws_api_gateway_resource.file.id
  http_method = aws_api_gateway_method.upload_file.http_method
  status_code = aws_api_gateway_method_response.post_upload_file.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'http://localhost'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
  }
}

# To Handle CORS, need to have the options method for get presigned URL
resource "aws_api_gateway_method" "options_presigned_url" {
  rest_api_id   = aws_api_gateway_rest_api.doc_api.id
  resource_id   = aws_api_gateway_resource.presigned_url.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_presigned_url" {
  rest_api_id             = aws_api_gateway_rest_api.doc_api.id
  resource_id             = aws_api_gateway_resource.presigned_url.id
  http_method             = aws_api_gateway_method.options_presigned_url.http_method
  type                    = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_presigned_url" {
  rest_api_id = aws_api_gateway_rest_api.doc_api.id
  resource_id = aws_api_gateway_resource.presigned_url.id
  http_method = aws_api_gateway_method.options_presigned_url.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options_presigned_url" {
  rest_api_id = aws_api_gateway_rest_api.doc_api.id
  resource_id = aws_api_gateway_resource.presigned_url.id
  http_method = aws_api_gateway_method.options_presigned_url.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'http://localhost'"
  }

  response_templates = {
    "application/json" = ""
  }
}



resource "aws_api_gateway_method_response" "post_presigned_url" {
  rest_api_id = aws_api_gateway_rest_api.doc_api.id
  resource_id = aws_api_gateway_resource.presigned_url.id
  http_method = aws_api_gateway_method.get_presigned_url.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "post_presigned_url" {
  rest_api_id = aws_api_gateway_rest_api.doc_api.id
  resource_id = aws_api_gateway_resource.presigned_url.id
  http_method = aws_api_gateway_method.get_presigned_url.http_method
  status_code = aws_api_gateway_method_response.post_presigned_url.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'http://localhost'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
  }
}