resource "aws_api_gateway_rest_api" "doc_api" {
  name        = "DocumentSharingAPI"
  description = "API for the secure document sharing system."
}

resource "aws_api_gateway_authorizer" "cognito_authorizer" {
  name                   = "CognitoAuthorizer"
  rest_api_id            = aws_api_gateway_rest_api.doc_api.id
  identity_source        = "method.request.header.Authorization"
  provider_arns          = [var.cognito_user_pool_arn]
  type                   = "COGNITO_USER_POOLS"
}
#
resource "aws_lambda_permission" "api_gateway_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_permission" "allow_api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.cognito_user_lambda_function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_api_gateway_deployment" "doc_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.doc_api.id

  depends_on = [
    aws_api_gateway_integration.upload_file_lambda,
    aws_api_gateway_integration.get_presigned_url_lambda
  ]
}

resource "aws_api_gateway_stage" "dev_stage" {
  rest_api_id   = aws_api_gateway_rest_api.doc_api.id
  stage_name    = var.stage_name
  deployment_id = aws_api_gateway_deployment.doc_api_deployment.id

  lifecycle {
    ignore_changes = [
      deployment_id,
    ]
  }
}

resource "aws_api_gateway_method_settings" "doc_api_method_settings" {
  rest_api_id = aws_api_gateway_rest_api.doc_api.id
  stage_name  = aws_api_gateway_stage.dev_stage.stage_name
  method_path = "${aws_api_gateway_resource.file.path_part}/${aws_api_gateway_method.upload_file.http_method}"

  settings {
    data_trace_enabled = true
    logging_level      = "INFO"
    metrics_enabled    = true
  }
}

