variable "env_name" {
    type = string
}

variable "source_repository" {
    type = string
}

variable "build_codebuild_projects" {
    type = list(string)
}

variable "test_codebuild_projects" {
    type = list(string)
}

variable "post_codebuild_projects" {
    type = list(string)
}

variable "merge_codebuild_projects" {
    type = list(string)
}

variable "s3_bucket" {
    type = string
}

variable "target_bucket" {
    
}

variable "test_bucket" {
    
}

variable "app_name" {
  default = "chorus"
}

variable "pipeline_type" {
}