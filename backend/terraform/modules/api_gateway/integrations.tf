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