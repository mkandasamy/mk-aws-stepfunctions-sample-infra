provider "aws" {
  region     = "us-east-2"
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.lambda_role_name}"
  assume_role_policy = "${file("${path.module}/policies/lambda-role.json")}"
}

resource "aws_lambda_function" "default" {
  count                          = "${length(var.lambda_variables)}"
  function_name                  = "${lookup(var.lambda_variables[count.index],"name")}-${var.environment}"
  handler                        = "${lookup(var.lambda_variables[count.index],"function_handler")}"
  role                           = "${aws_iam_role.lambda_role.arn}"
  description                    = "Lambda function for ${var.app_name} application in ${var.environment}."
  runtime                        = "${lookup(var.lambda_variables[count.index],"lambda_runtime")}"
  memory_size                    = "${lookup(var.lambda_variables[count.index],"lambda_memory_size")}"
  timeout                        = "${lookup(var.lambda_variables[count.index],"lambda_timeout")}"
  publish                        = "${lookup(var.lambda_variables[count.index],"lambda_publish")}"
  reserved_concurrent_executions = "${lookup(var.lambda_variables[count.index],"reserved_concurrent_executions")}"
  filename         				 = "${path.module}/artifacts/${lookup(var.lambda_variables[count.index],"name")}.zip"
}