locals {
  app_name              = var.app_name == null ? var.pipeline_config.app_name : var.app_name
  env_type              = var.env_type == null ? var.pipeline_config.env_type : var.env_type
  env_name              = var.env_name == null ? var.pipeline_config.env_name : var.env_name
  from_env              = var.from_env == null ? var.pipeline_config.from_env : var.from_env
  pipeline_type         = var.pipeline_type == null ? var.pipeline_config.pipeline_type : var.pipeline_type
  target_bucket         = var.target_bucket == null ? var.pipeline_config.target_bucket : var.target_bucket
  test_bucket           = var.test_bucket == null ? var.pipeline_config.test_bucket : var.test_bucket
  run_integration_tests = var.run_integration_tests == null ? var.pipeline_config.run_integration_tests : var.run_integration_tests
  source_repository     = var.source_repository == null ? "tolunaengineering/${local.app_name}" : var.source_repository
  src_bucket            = var.src_bucket == null ? var.pipeline_config.src_bucket : var.src_bucket
  vpc_config             = var.vpc_config.vpc_id == "NULL" ? merge(var.pipeline_config.vpc_config, { security_group_ids = var.security_group_ids }) : var.vpc_config
  artifacts_bucket_name = "s3-codepipeline-${local.app_name}-${local.env_type}"
}

module "ci-cd-code-pipeline" {
  source                   = "./modules/ci-cd-codepipeline"
  env_name                 = local.env_name
  app_name                 = local.app_name
  pipeline_type            = local.pipeline_type
  source_repository        = local.source_repository
  s3_bucket                = local.artifacts_bucket_name
  target_bucket            = local.target_bucket
  test_bucket              = local.test_bucket
  build_codebuild_projects = [module.build.attributes.name]
  post_codebuild_projects  = [module.post.attributes.name]
  test_codebuild_projects  = [module.test.attributes.name]
  merge_codebuild_projects = local.pipeline_type != "dev" ? ["Merge-Waiter"] : []
  depends_on = [
    module.build,
    module.post,
    module.test
  ]
}

module "build" {
  source                                = "./modules/build"
  env_name                              = local.env_name
  env_type                              = local.env_type
  codebuild_name                        = "build-${local.app_name}"
  source_repository                     = local.source_repository
  s3_bucket                             = local.artifacts_bucket_name
  privileged_mode                       = true
  environment_variables_parameter_store = var.environment_variables_parameter_store
  vpc_config                            = local.vpc_config
  environment_variables                 = merge(var.environment_variables, { APP_NAME = "${local.app_name}", ENV_TYPE = "${local.env_type}", HOOKS = local.run_integration_tests, PIPELINE_TYPE = local.pipeline_type }) //TODO: try to replace with file
  buildspec_file = templatefile("buildspec.yml.tpl",
    { APP_NAME             = local.app_name,
      ENV_TYPE             = local.env_type,
      ENV_NAME             = local.env_name,
      FROM_ENV             = local.from_env,
      PIPELINE_TYPE        = local.pipeline_type,
      ADO_PASSWORD         = data.aws_ssm_parameter.ado_password.value,
      REPO_NAME            = local.source_repository,
      BUCKET               = local.target_bucket
      TEST_DISTRIBUTION_ID = var.test_distribution_id
      SRC_BUCKET           = local.src_bucket
  })
}

module "test" {
  source                                = "./modules/test"
  env_name                              = local.env_name
  env_type                              = local.env_type
  codebuild_name                        = "test-${local.app_name}"
  source_repository                     = local.source_repository
  s3_bucket                             = "s3-codepipeline-${local.app_name}-${local.env_type}"
  privileged_mode                       = true
  environment_variables_parameter_store = var.environment_variables_parameter_store
  buildspec_file = templatefile("${path.module}/templates/test_buildspec.yml.tpl",
    { ENV_NAME             = local.env_name,
      FROM_ENV             = local.from_env,
      APP_NAME             = local.app_name,
      ENV_TYPE             = local.env_type,
      REPO_NAME            = local.source_repository,
      BUCKET               = local.target_bucket,
      DISTRIBUTION_ID      = var.distribution_id,
      CYPRESS_RECORD_TESTS = var.cypress_record_tests
      CYPRESS_RECORD_KEY   = var.cypress_record_key
  })

}

module "post" {
  source                                = "./modules/post"
  env_name                              = local.env_name
  env_type                              = local.env_type
  codebuild_name                        = "post-${local.app_name}"
  source_repository                     = local.source_repository
  s3_bucket                             = "s3-codepipeline-${local.app_name}-${local.env_type}"
  privileged_mode                       = true
  environment_variables_parameter_store = var.environment_variables_parameter_store
  buildspec_file = templatefile("${path.module}/templates/post_buildspec.yml.tpl",
    { ENV_NAME             = local.env_name,
      FROM_ENV             = local.from_env,
      APP_NAME             = local.app_name,
      ENV_TYPE             = local.env_type,
      REPO_NAME            = local.source_repository,
      PIPELINE_TYPE        = local.pipeline_type,
      BUCKET               = local.target_bucket,
      TEST_BUCKET          = local.test_bucket,
      DISTRIBUTION_ID      = var.distribution_id
      TEST_DISTRIBUTION_ID = var.test_distribution_id
  })
}
