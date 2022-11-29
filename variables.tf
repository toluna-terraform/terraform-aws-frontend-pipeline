variable "env_name" {
    type = string
}

variable "from_env" {
    type = string
}

variable "app_name" {
    type = string
}

variable "env_type" {
    type = string
}

variable "run_integration_tests" {
    type = bool
    default = false
}

variable "source_repository" {
    type = string
}

variable "trigger_branch" {
    type     = string
 }

variable "environment_variables_parameter_store" {
 type = map(string)
 default = {
    "ADO_USER" = "/app/ado_user",
    "ADO_PASSWORD" = "/app/ado_password"
 }
}

variable "environment_variables" {
 type = map(string)
 default = {
 }
}

variable "pipeline_type" {
  type = string
}

variable "termination_wait_time_in_minutes" {
  default = 120
}

variable "target_bucket" {

}

variable "test_bucket" {

}

variable "distribution_id" {

}

variable "src_bucket" {

}

variable "test_distribution_id" {

}

variable "cypress_record_tests" {
  type = bool
  default = false
}

variable "cypress_record_key" {
  type = string
  default = ""
}

variable "vpc_config" {
  default = {}
}