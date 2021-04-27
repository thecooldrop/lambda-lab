// Welcome to IaC part of the lab, here we are going to be configuring our
// infrastructure as code. This document is organized to traversed from top-to-bottom so that the necessary
// resources can be provisioned by commenting out pieces of code and executing indicated commands.

// As you can see we have large number of code blocks which have been commented out. We are going to leave
// them commented out in the first run, and we are going to be removing the comments as we move forward in the lab

// In your terminal, or in your favorite code-editor with terminal support, navigate to the directory containing the
// main.tf file and proceed to execute the following command:

// terraform init
// terraform apply

// This is going to initialize Terraform project with required plugins, in order to enable provisioning infrastructure
// with your chosen cloud-providers and provision the pieces of infrastructure which are not commented out ( which
// is none in this first step ).

// As bonus exercise after turning on blocks of code, try to add your own comments describing what these blocks
// of code are doing.


terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  version = "3.37.0"
  region = "eu-central-1"
}


///////////////////////////////////////////////////////////////////////////////////////////////////////
//   _____ _______       _____ ______    ___
//  / ____|__   __|/\   / ____|  ____|  / _ \
// | (___    | |  /  \ | |  __| |__    | | | |
//  \___ \   | | / /\ \| | |_ |  __|   | | | |
//  ____) |  | |/ ____ \ |__| | |____  | |_| |
// |_____/   |_/_/    \_\_____|______|  \___/
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

// In this first stage we are going to provision our persistence solution, consisting of an S3 bucket
// and a single file uploaded to this bucket.

// Comment out the following two blocks of code and execute following command in your terminal:

// terraform apply

//resource "aws_s3_bucket" "tasks_bucket" {
//  bucket = "frauenhofer-tasks-lambda-bucket"
//  versioning {
//    enabled = true
//  }
//}
//
//resource "aws_s3_bucket_object" "tasks_file" {
//  bucket = aws_s3_bucket.tasks_bucket.bucket
//  key = "tasks.json"
//  source = "${path.cwd}/tasks.json"
//}



//////////////////////////////////////////////////////////////////////////////////
//   _____ _______       _____ ______   __
//  / ____|__   __|/\   / ____|  ____| /_ |
// | (___    | |  /  \ | |  __| |__     | |
//  \___ \   | | / /\ \| | |_ |  __|    | |
//  ____) |  | |/ ____ \ |__| | |____   | |
// |_____/   |_/_/    \_\_____|______|  |_|
//////////////////////////////////////////////////////////////////////////////////

// In this stage we are going to provision our Lambda function, the necessary resources to enable
// logging during execution of Lambda function, the roles and access policies to enable the Lambda function to
// access the S3 bucket and to write logs into designated log groups.

// Comment out next five code blocks and execute the following command again:

// terraform apply



//resource "aws_lambda_function" "tasks_lambda" {
//  function_name = "tasks_lambda"
//  handler = "app.lambda_handler"
//  role = aws_iam_role.tasks_lambda_role.arn
//  runtime = "python3.8"
//  filename = "${path.cwd}/app.zip"
//  timeout = 10
//  environment {
//    variables = {
//      BUCKET_NAME = aws_s3_bucket.tasks_bucket.bucket
//      FILEPATH = aws_s3_bucket_object.tasks_file.key
//    }
//  }
//}
//
//resource "aws_cloudwatch_log_group" "tasks_lambda_log_group" {
//  name = "/aws/lambda/${aws_lambda_function.tasks_lambda.function_name}"
//  retention_in_days = 14
//}
//
//
//
//resource "aws_iam_policy" "lambda_function_policy" {
//  name = "frauenhofer_lambda_policy"
//  description = "Policy to allow full access to S3 for Lambda function and to Cloudwatch LogGroup"
//  policy = jsonencode({
//    Version = "2012-10-17"
//    Statement = [
//      {
//        Effect = "Allow"
//        Action = ["s3:*"]
//        Resource = "*"
//      },
//      {
//        Effect = "Allow"
//        Action = [
//          "logs:CreateLogStream",
//          "logs:PutLogEvents",
//          "logs:CreateLogGroup"
//        ]
//        Resource = "arn:aws:logs:*:*:*"
//      }
//    ]
//  })
//}
//
//resource "aws_iam_role" "tasks_lambda_role" {
//  assume_role_policy = jsonencode({
//    Version = "2012-10-17"
//    Statement = [
//      {
//        Effect = "Allow"
//        Principal = {
//          "Service" = "lambda.amazonaws.com"
//        }
//        Action = "sts:AssumeRole"
//      }
//    ]
//  })
//}
//
//
//resource "aws_iam_role_policy_attachment" "task_lambda_role_binding" {
//  policy_arn = aws_iam_policy.lambda_function_policy.arn
//  role = aws_iam_role.tasks_lambda_role.name
//}


//////////////////////////////////////////////////////////////////////////////////////////
//   _____ _______       _____ ______   ___
//  / ____|__   __|/\   / ____|  ____| |__ \
// | (___    | |  /  \ | |  __| |__       ) |
//  \___ \   | | / /\ \| | |_ |  __|     / /
//  ____) |  | |/ ____ \ |__| | |____   / /_
// |_____/   |_/_/    \_\_____|______| |____|
//////////////////////////////////////////////////////////////////////////////////////////

// Lastly we are going to configure our API gateway to enable access to our  service. The drill is the same as
// before, comment out the remaining code blocks and execute the terraform apply command.

// Do not forget to try to add comments explaining what each of the resources is doing.

//resource "aws_apigatewayv2_api" "tasks_lambda_api" {
//  name = "tasks-lambda-api"
//  protocol_type = "HTTP"
//}



//resource "aws_apigatewayv2_integration" "tasks_lambda_integration" {
//  api_id = aws_apigatewayv2_api.tasks_lambda_api.id
//  integration_type = "AWS_PROXY"
//  integration_uri = aws_lambda_function.tasks_lambda.invoke_arn
//  payload_format_version = "2.0"
//}


//resource "aws_apigatewayv2_route" "get_tasks_route" {
//  api_id = aws_apigatewayv2_api.tasks_lambda_api.id
//  route_key = "GET /tasks"
//  target = "integrations/${aws_apigatewayv2_integration.tasks_lambda_integration.id}"
//}


//resource "aws_apigatewayv2_route" "post_tasks_route" {
//  api_id = aws_apigatewayv2_api.tasks_lambda_api.id
//  route_key = "POST /tasks"
//  target = "integrations/${aws_apigatewayv2_integration.tasks_lambda_integration.id}"
//}


//resource "aws_apigatewayv2_stage" "default" {
//  api_id = aws_apigatewayv2_api.tasks_lambda_api.id
//  name = "$default"
//  auto_deploy = true
//}


//resource "aws_lambda_permission" "api_call_permission" {
//  action = "lambda:InvokeFunction"
//  function_name = aws_lambda_function.tasks_lambda.arn
//  principal = "apigateway.amazonaws.com"
//}


//data "aws_apigatewayv2_api" "api-endpoint-url-data" {
//  api_id = aws_apigatewayv2_api.tasks_lambda_api.id
//}


//output "aws-endpoint-url" {
//  value = "${data.aws_apigatewayv2_api.api-endpoint-url-data.api_endpoint}/tasks"
//}


//////////////////////////////////////////////////////////////////////////////////////
//   _____ _
//  / ____| |
// | |    | | ___  __ _ _ __  _   _ _ __
// | |    | |/ _ \/ _` | '_ \| | | | '_ \
// | |____| |  __/ (_| | | | | |_| | |_) |
//  \_____|_|\___|\__,_|_| |_|\__,_| .__/
//                                 | |
//                                 |_|
/////////////////////////////////////////////////////////////////////////////////////

// Remember how we said that cleaning-up behind yourself may be hard if resources are configured by hand in AWS console ?
// With IaC that is not the case anymore. To stop using resources which you have provisioned and to stop spending money
// on them, only a single command is necessary.

// Execute the following command and watch the budget going green again:

// terraform destroy