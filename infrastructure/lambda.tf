variable "build_number" {}

provider "aws" {
  region = "us-east-1"
}

resource "aws_lambda_function" "PlayLambdaApiLambda" {
  function_name = "PlayLambdaApiLambda"

  # The bucket name as created earlier with "aws s3api create-bucket"
  s3_bucket = "playplace-builds"
  s3_key    = "PlayLambdaApi/play-lambda-api-${var.build_number}.zip"

  # "main" is the filename within the zip file (main.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  handler = "index.handler"
  runtime = "nodejs8.10"

  role = "${aws_iam_role.PlayLambdaApiLambdaRole.arn}"
  tags = {
    cost-allocation = "play-${var.environment}"
    environment = "${var.environment}"
  }
}

# IAM role which dictates what other AWS services the Lambda function
# may access.
resource "aws_iam_role" "PlayLambdaApiLambdaRole" {
  name = "playplace_PlayLambdaApi_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "PlayLambdaApiLambdaRoleLambdaBasicPolicy" {
  role       = "${aws_iam_role.PlayLambdaApiLambdaRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# TODO Change retention based on environment
resource "aws_cloudwatch_log_group" "PlayLambdaApiLambdaLog" {
  name = "/aws/lambda/${aws_lambda_function.PlayLambdaApiLambda.function_name}"
  retention_in_days = 14,
  tags {
    cost-allocation = "play-${var.environment}"
    environment = "${var.environment}"
  }
}