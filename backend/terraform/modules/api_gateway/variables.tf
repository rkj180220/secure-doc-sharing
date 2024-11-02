variable "lambda_function_arn" {
  description = "The ARN of the Lambda function."
  type        = string
}

variable "lambda_function_invoke_arn" {
  description = "The Invoke ARN of the Lambda function."
  type        = string
}

variable "lambda_function_name" {
  description = "The ARN of the Lambda function."
  type        = string
}

variable "stage_name" {
  description = "The name of the API Gateway stage"
  type        = string
  default     = "dev_env"  # You can change the default value if needed
}

variable "region" {
  description = "The AWS region to deploy to."
  default     = "us-east-1"
}

variable "cognito_user_pool_id" {
  description = "The ID of the Cognito User Pool"
  type        = string
  default = "us-east-1_e0s6Me24U"
}

variable "cognito_user_pool_client_id" {
  description = "The client ID of the Cognito User Pool"
  type        = string
  default = "3reis4moiaeu4ted76sdpii2tq"
}

variable "cognito_user_pool_arn" {
  description = "The ARN of the Cognito User Pool"
  type        = string
  default = "arn:aws:cognito-idp:us-east-1:903051706172:userpool/us-east-1_e0s6Me24U"
}