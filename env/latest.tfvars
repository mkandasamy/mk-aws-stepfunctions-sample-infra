app_name		 		= "mk-aws-stepfunctions-sample"
environment		 		= "latest"
region					= "us-east-2"
account_id				= "203532026745"
lambda_role_name 		= "mk-aws-stepfunctions-sample-lambda-role"
stepfunction_name		= "mk-aws-stepfunctions-sample"
stepfunction_role_name  = "mk-aws-stepfunctions-sample-role"


lambda_variables = [
  {
    "name"                           = "mk-aws-stepfunctions-sample-lambda"
    "function_handler"               = "iterator.handler"
    "lambda_runtime"                 = "nodejs6.10"
    "lambda_memory_size"             = "128"
    "lambda_timeout"                 = "3"
    "lambda_publish"                 = "true"
    "reserved_concurrent_executions" = "10"
    "retention_in_days"              = "90"
  }
]