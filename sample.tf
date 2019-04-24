provider "aws" {
  region     = "us-east-2"
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.lambda_role_name}"
  assume_role_policy = "${file("${path.module}/policies/lambda-role.json")}"
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.lambda_role_name}-policy"
  role = "${aws_iam_role.lambda_role.id}"
  policy = "${file("${path.module}/policies/lambda-role-policy.json")}"
}

resource "aws_iam_role" "stepfunction_role" {
  name = "${var.stepfunction_role_name}"
  assume_role_policy = "${file("${path.module}/policies/stepfunction-role.json")}"
}

resource "aws_iam_role_policy" "stepfunction_policy" {
  name = "${var.stepfunction_role_name}-policy"
  role = "${aws_iam_role.stepfunction_role.id}"
  policy = "${file("${path.module}/policies/stepfunction-role-policy.json")}"
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

data "template_file" "sfn_state_machine_data" {
  template = "${file("${path.module}/artifacts/mk-aws-stepfunctions-sample.sf")}"

  vars {
    region                    = "${var.region}"
    account_id                = "${var.account_id}"
    lambda_name               = "${lookup(var.lambda_variables[count.index],"name")}-${var.environment}"
  }
}

resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "${var.stepfunction_name}"
  role_arn = "${aws_iam_role.stepfunction_role.arn}"

  definition = "${data.template_file.sfn_state_machine_data.rendered}"
}