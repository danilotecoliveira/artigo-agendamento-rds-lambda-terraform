provider "aws" {
  region  = "${var.region}"
}


resource "aws_iam_policy" "schedule_rds_policy" {
  name          = "${var.policy_name}"
  description   = "${var.policy_description}"
  policy        = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {           
            "Effect": "Allow",
            "Action": [
                "rds:Stop*",
                "rds:Start*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}


resource "aws_iam_role" "schedule_rds_role" {
  name                  = "${var.role_name}"
  description           = "${var.role_description}"
  assume_role_policy    = <<EOF
{
    "Version": "2012-10-17",
    "Statement": 
    [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "schedule_iam_attachment" {
  role          = "${aws_iam_role.schedule_rds_role.name}"
  policy_arn    = "${aws_iam_policy.schedule_rds_policy.arn}"
}


data "archive_file" "file_lambda" {
  type = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}


resource "aws_lambda_function" "schedule_rds_lambda" {
  filename          = "${data.archive_file.file_lambda.output_path}"
  function_name     = "${var.lambda_function_name}"
  role              = "${aws_iam_role.schedule_rds_role.arn}"
  handler           = "${var.lambda_handler}"
  timeout           = "${var.lambda_timeout}"
  source_code_hash  = "${data.archive_file.file_lambda.output_base64sha256}"
  runtime           = "python3.8"

  environment {
    variables = {
      dbinstances = "${var.lambda_dbinstances}"
    }
  }
}


resource "aws_cloudwatch_event_rule" "schedule_cloudwatch" {
  name                  = "${var.cloudwatch_name}"
  description           = "${var.cloudwatch_description}"
  schedule_expression   = "rate(60 minutes)"
}


resource "aws_cloudwatch_event_target" "schedule_cloudwatch_target" {
  rule      = "${aws_cloudwatch_event_rule.schedule_cloudwatch.name}"
  target_id = "lambdaRDS"
  arn       = "${aws_lambda_function.schedule_rds_lambda.arn}"
}
