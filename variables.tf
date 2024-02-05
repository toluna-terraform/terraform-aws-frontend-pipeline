variable "pipeline_config" {
  #type = map(string)
}

variable "env_name" {
  type     = string
  default  = null
  nullable = true
}

variable "from_env" {
  type     = string
  default  = null
  nullable = true
}

variable "app_name" {
  type     = string
  default  = null
  nullable = true
}

variable "env_type" {
  type     = string
  default  = null
  nullable = true
}

variable "run_integration_tests" {
  type     = bool
  default  = null
  nullable = true
}

variable "source_repository" {
  type     = string
  default  = null
  nullable = true
}

variable "trigger_branch" {
  type     = string
  default  = null
  nullable = true
}

variable "environment_variables_parameter_store" {
  type = map(string)
  default = {
    "ADO_USER"     = "/app/ado_user",
    "ADO_PASSWORD" = "/app/ado_password"
  }
}

variable "environment_variables" {
  type = map(string)
  default = {
  }
}

variable "pipeline_type" {
  type     = string
  default  = null
  nullable = true
}

variable "termination_wait_time_in_minutes" {
  default = 120
}

variable "target_bucket" {
  type     = string
  default  = null
  nullable = true
}

variable "test_bucket" {
  type     = string
  default  = null
  nullable = true
}

variable "distribution_id" {

}

variable "src_bucket" {
  type     = string
  default  = null
  nullable = true
}

variable "test_distribution_id" {

}

variable "cypress_record_tests" {
  type    = bool
  default = false
}

variable "cypress_record_key" {
  type    = string
  default = ""
}

variable "vpc_config" {
  default = {
     vpc_id             = "NULL",
      subnets            = [],
      security_group_ids = []
  }
}

variable "security_group_ids" {
  type = list(string)
  default = []
}