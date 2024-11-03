resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "lambda_policy"
  role   = aws_iam_role.lambda_exec.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ],
        Resource = "${var.s3_bucket_arn}/*",
        Effect   = "Allow"
      },
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query"
        ],
        Resource = [
          "${var.dynamodb_table_arn}",
          "${var.dynamodb_table_arn}/index/UserID-index"
        ],
        Effect   = "Allow"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*",
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_lambda_function" "file_operations" {
  function_name = "FileOperations"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "file_operations.lambda_handler"
  runtime       = "python3.9"

  environment {
    variables = {
      S3_BUCKET     = var.s3_bucket
      DYNAMODB_TABLE = var.dynamodb_table
    }
  }

  # The ZIP file containing the Lambda code
  filename         = "lambda.zip"
  source_code_hash = filebase64sha256("lambda.zip")
}

# S3 Event Notification

resource "aws_lambda_permission" "allow_s3_to_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.file_operations.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_bucket_arn
}

resource "aws_s3_bucket_notification" "secure_document_storage_notification" {
  bucket = var.s3_bucket_id

  lambda_function {
    lambda_function_arn = aws_lambda_function.file_operations.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

output "function_name" {
  value = aws_lambda_function.file_operations.function_name
}

# modules/lambda/outputs.tf
output "lambda_function_arn" {
  value = aws_lambda_function.file_operations.arn
}

output "lambda_invoke_arn" {
  value = aws_lambda_function.file_operations.invoke_arn
}


# Cognito Lambda

resource "aws_iam_role" "list_cognito_users_exec" {
  name = "list_cognito_users_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "list_cognito_users_policy" {
  name   = "list_cognito_users_policy"
  role   = aws_iam_role.list_cognito_users_exec.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "cognito-idp:ListUsers"
        ],
        Resource = "*",
        Effect   = "Allow"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*",
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_lambda_function" "list_cognito_users" {
  function_name = "ListCognitoUsers"
  role          = aws_iam_role.list_cognito_users_exec.arn
  handler       = "cognito_operations.lambda_handler"
  runtime       = "python3.9"

  environment {
    variables = {
      COGNITO_USER_POOL_ID = var.cognito_user_pool_id
    }
  }

  filename         = "cognito.zip"
  source_code_hash = filebase64sha256("cognito.zip")
}

output "list_cognito_users_function_name" {
  value = aws_lambda_function.list_cognito_users.function_name
}

output "list_cognito_users_function_arn" {
  value = aws_lambda_function.list_cognito_users.arn
}

output "list_cognito_users_invoke_arn" {
  value = aws_lambda_function.list_cognito_users.invoke_arn
}