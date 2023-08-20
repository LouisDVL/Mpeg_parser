provider "aws" {
  region = "ap-southeast-2"  # Change this to your desired region
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name = "/aws/lambda/file-parser-lambda"
}

resource "aws_s3_bucket" "quarantine_bucket" {
  bucket = "spalk-quarantine-bucket"
}

resource "aws_s3_bucket" "spalk_bucket" {
  bucket = "spalk"
}

resource "aws_lambda_function" "MPEG_parser_lambda" {
  function_name = "file-parser-lambda"
  runtime       = "go1.x"
  handler       = "main"

  filename      = "./lambda/main.zip"
  source_code_hash = filebase64sha256("./lambda/main.zip")

  role = aws_iam_role.lambda_exec_role.arn
  
  environment {
    variables = {
      AWS_LAMBDA_EXECUTION_LOG_GROUP = aws_cloudwatch_log_group.lambda_log_group.name
      AWS_LAMBDA_EXECUTION_LOG_STREAM = "lambda-log-stream"
    }
  }
}


resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda-exec-role"

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

resource "aws_iam_role_policy_attachment" "lambda_cloudwatch_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_cloudwatch_policy.arn
  role       = aws_iam_role.lambda_exec_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_s3_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
  role       = aws_iam_role.lambda_exec_role.name
}

resource "aws_iam_policy" "lambda_cloudwatch_policy" {
  name        = "lambda-cloudwatch-policy"
  description = "Allows Lambda function to write logs to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = [
          aws_cloudwatch_log_group.lambda_log_group.arn,
          "${aws_cloudwatch_log_group.lambda_log_group.arn}:*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_s3_policy" {
  name = "lambda-s3-policy"
  description = "Allows Lambda function to get files from s3"

  policy = jsonencode({
        "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:ListBucket",
                "s3:PutObject",
            ],
            "Resource": [
                aws_s3_bucket.quarantine_bucket.arn,
                "${aws_s3_bucket.quarantine_bucket.arn}/*",
                aws_s3_bucket.spalk_bucket.arn,
                "${aws_s3_bucket.spalk_bucket.arn}/*"
            ]
        }
    ]
  })
}






