variable "s3_bucket" {
  description = "The S3 bucket to store files."
  type        = string
  default = "secure-doc-storage-eedd873462f7b541"
}

variable "s3_bucket_arn" {
  description = "The S3 bucket arn to store files."
  type        = string
}

variable "s3_bucket_id" {
  description = "The S3 bucket id to store files."
  type        = string
}


variable "dynamodb_table" {
  description = "The DynamoDB table for metadata."
  type        = string
  default = "FileMetadata"
}

variable "dynamodb_table_arn" {
  description = "The DynamoDB table for metadata."
  type        = string
}

variable "cognito_user_pool_id" {
    description = "Cognito User Pool ID"
    type        = string
    default = "us-east-1_e0s6Me24U"
}
