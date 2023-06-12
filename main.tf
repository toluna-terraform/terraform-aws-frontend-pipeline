locals {
  artifacts_bucket_name = "s3-codepipeline-${var.app_name}-${var.env_type}"
}

module "ci-cd-code-pipeline" {
  source                       = "./modules/ci-cd-codepipeline"
  env_name                     = var.env_name
  app_name                     = var.app_name
  pipeline_type                = var.pipeline_type
  source_repository            = var.source_repository
  s3_bucket                    = local.artifacts_bucket_name
  target_bucket                = var.target_bucket
  test_bucket                  = var.test_bucket
  build_codebuild_projects     = [module.build.attributes.name]
  post_codebuild_projects      = [module.post.attributes.name]
  test_codebuild_projects      = [module.test.attributes.name]
  merge_codebuild_projects     = var.pipeline_type != "dev" ? ["Merge-Waiter"] : []
  depends_on = [
    module.build,
    module.post,
    module.test
  ]
}



module "build" {
  source                                = "./modules/build"
  env_name                              = var.env_name
  env_type                              = var.env_type
  codebuild_name                        = "build-${var.app_name}"
  source_repository                     = var.source_repository
  s3_bucket                             = local.artifacts_bucket_name
  privileged_mode                       = true
  environment_variables_parameter_store = var.environment_variables_parameter_store
  vpc_config                            = var.vpc_config
  environment_variables                 = merge(var.environment_variables, {APP_NAME = "${var.app_name}", ENV_TYPE = "${var.env_type}", HOOKS = var.run_integration_tests, PIPELINE_TYPE = var.pipeline_type}) //TODO: try to replace with file
  buildspec_file                        = templatefile("buildspec.yml.tpl",
  { APP_NAME = var.app_name,
    ENV_TYPE = var.env_type,
    ENV_NAME = var.env_name,
    FROM_ENV = var.from_env,
    PIPELINE_TYPE = var.pipeline_type,
    ADO_PASSWORD = data.aws_ssm_parameter.ado_password.value,
    REPO_NAME = var.source_repository,
    BUCKET = var.target_bucket
    TEST_DISTRIBUTION_ID = var.test_distribution_id
    SRC_BUCKET = var.src_bucket
  })
}

module "test" {
  source                                = "./modules/test"
  env_name                              = var.env_name
  env_type                              = var.env_type
  codebuild_name                        = "test-${var.app_name}"
  source_repository                     = var.source_repository
  s3_bucket                             = "s3-codepipeline-${var.app_name}-${var.env_type}"
  privileged_mode                       = true
  environment_variables_parameter_store = var.environment_variables_parameter_store
  buildspec_file                        = templatefile("${path.module}/templates/test_buildspec.yml.tpl",
  { ENV_NAME = split("-",var.env_name)[0],
    FROM_ENV = var.from_env,
    APP_NAME = var.app_name,
    ENV_TYPE = var.env_type,
    REPO_NAME = var.source_repository,
    BUCKET = var.target_bucket,
    DISTRIBUTION_ID = var.distribution_id,
    CYPRESS_RECORD_TESTS = var.cypress_record_tests
    CYPRESS_RECORD_KEY = var.cypress_record_key
    })

}

module "post" {
  source                                = "./modules/post"
  env_name                              = var.env_name
  env_type                              = var.env_type
  codebuild_name                        = "post-${var.app_name}"
  source_repository                     = var.source_repository
  s3_bucket                             = "s3-codepipeline-${var.app_name}-${var.env_type}"
  privileged_mode                       = true
  environment_variables_parameter_store = var.environment_variables_parameter_store
  buildspec_file                        = templatefile("${path.module}/templates/post_buildspec.yml.tpl",
  { ENV_NAME = split("-",var.env_name)[0],
    FROM_ENV = var.from_env,
    APP_NAME = var.app_name,
    ENV_TYPE = var.env_type,
    REPO_NAME = var.source_repository,
    PIPELINE_TYPE = var.pipeline_type,
    BUCKET = var.target_bucket,
    TEST_BUCKET = var.test_bucket,
    DISTRIBUTION_ID = var.distribution_id
    TEST_DISTRIBUTION_ID = var.test_distribution_id
    })
}