output "api_endpoint" {
  value = "https://${aws_api_gateway_rest_api.doc_api.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.dev_stage.stage_name}/file/presignedURL"
}