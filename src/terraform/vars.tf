variable "policy_name" { 
  default = "ScheduleRDSPolicy"
}

variable "policy_description" { 
  default = "Policy que permite o Lambda a desligar e ligar as instâncias do RDS"
}

variable "role_name" { 
  default = "ScheduleRDSRole"
}

variable "role_description" { 
  default = "Role que permite o Lambda a desligar e ligar as instâncias do RDS"
}

variable "lambda_function_name" { 
  default = "ScheduleRDSLambda"
}

variable "lambda_handler" { 
  default = "lambda_function.lambda_handler"
}

variable "lambda_timeout" { 
  default = "10"
}

variable "lambda_dbinstances" { 
  default = "my-sql-server-db,my-postgres-db"
}

variable "cloudwatch_name" { 
  default = "ScheduleRDSCloudwatch"
}

variable "cloudwatch_description" { 
  default = "Liga e desliga os recursos do RDS"
}
