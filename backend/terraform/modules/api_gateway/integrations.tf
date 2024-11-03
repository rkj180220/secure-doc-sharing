resource "aws_api_gateway_integration" "upload_file_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.doc_api.id
  resource_id             = aws_api_gateway_resource.file.id
  http_method             = aws_api_gateway_method.upload_file.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_function_invoke_arn
}

resource "aws_api_gateway_integration" "get_presigned_url_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.doc_api.id
  resource_id             = aws_api_gateway_resource.presigned_url.id
  http_method             = aws_api_gateway_method.get_presigned_url.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_function_invoke_arn
}

resource "aws_api_gateway_integration" "get_list_cognito_users" {
  rest_api_id             = aws_api_gateway_rest_api.doc_api.id
  resource_id             = aws_api_gateway_resource.list_cognito_users.id
  http_method             = aws_api_gateway_method.get_list_cognito_users.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.cognito_user_lambda_invoke_arn
}

resource "aws_api_gateway_integration" "share_file_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.doc_api.id
  resource_id             = aws_api_gateway_resource.share_file.id
  http_method             = aws_api_gateway_method.share_file.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_function_invoke_arn
}