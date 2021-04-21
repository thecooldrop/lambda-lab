terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket = "frauenhofer-lambda-infra-state-bucket"
    key = "global/s3/terraform.tfstate"
    region = "eu-central-1"

    dynamodb_table = "terraform-frauenhofer-locks"
    encrypt = true
  }
}

provider "aws" {
  version = "3.13.0"
  region = "eu-central-1"
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "frauenhofer-lambda-infra-state-bucket"
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name = "terraform-frauenhofer-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_s3_bucket" "tasks_bucket" {
  bucket = "frauenhofer-tasks-lambda-bucket"
  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_object" "tasks_file" {
  bucket = aws_s3_bucket.tasks_bucket.bucket
  key = "tasks.json"
  source = "${path.cwd}/tasks.json"
}

resource "aws_cloudwatch_log_group" "tasks_lambda_log_group" {
  name = "/aws/lambda/${aws_lambda_function.tasks_lambda.function_name}"
  retention_in_days = 14
}

resource "aws_lambda_function" "tasks_lambda" {
  function_name = "tasks_lambda"
  handler = "app.lambda_handler"
  role = aws_iam_role.tasks_lambda_role.arn
  runtime = "python3.8"
  filename = "${path.cwd}/app.zip"
  timeout = 10
  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.tasks_bucket.bucket
      FILEPATH = aws_s3_bucket_object.tasks_file.key
    }
  }
}

resource "aws_iam_policy" "lambda_function_policy" {
  name = "frauenhofer_lambda_policy"
  description = "Policy to allow full access to S3 for Lambda function and to Cloudwatch LogGroup"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:*"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role" "tasks_lambda_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          "Service" = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "task_lambda_role_binding" {
  policy_arn = aws_iam_policy.lambda_function_policy.arn
  role = aws_iam_role.tasks_lambda_role.name
}

resource "aws_apigatewayv2_api" "tasks_lambda_api" {
  name = "tasks-lambda-api"
  protocol_type = "HTTP"
  route_key = "ANY /tasks"
  target = aws_lambda_function.tasks_lambda.arn
}

resource "aws_lambda_permission" "api_call_permission" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tasks_lambda.arn
  principal = "apigateway.amazonaws.com"
}