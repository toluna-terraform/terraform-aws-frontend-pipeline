locals {
  codepipeline_name = "codepipeline-${var.app_name}-${var.env_name}"
}

resource "aws_codepipeline" "codepipeline" {
  name     = local.codepipeline_name
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = var.s3_bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Download_Merged_Sources"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        S3Bucket             = "${var.s3_bucket}"
        S3ObjectKey          = "${var.env_name}/source_artifacts.zip"
        PollForSourceChanges = true
      }
    }
  }


  stage {
    name = var.pipeline_type
    dynamic "action" {
      for_each = var.build_codebuild_projects
      content {
        name             = action.value
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = ["source_output"]
        version          = "1"
        output_artifacts = var.pipeline_type == "dev" ? ["dev_output"] : ["cd_output"]

        configuration = {
          ProjectName = action.value
        }

      }

    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "S3"
      input_artifacts = var.pipeline_type == "dev" ? ["dev_output"] : ["cd_output"]
      version         = "1"
      run_order       = 1
      configuration = {
        BucketName = "${var.test_bucket}"
        CannedACL  = "public-read"
        Extract    = true
      }
    }
    dynamic "action" {
      for_each = var.test_codebuild_projects
      content {
        name            = action.value
        category        = "Test"
        owner           = "AWS"
        provider        = "CodeBuild"
        input_artifacts = ["source_output"]
        version         = "1"
        run_order       = 2
        configuration = {
          ProjectName = action.value
        }
      }
    }
    dynamic "action" {
      for_each = var.merge_codebuild_projects
      content {
        name            = action.value
        category        = "Approval"
        owner           = "AWS"
        provider        = "Manual"
        input_artifacts = []
        output_artifacts = []
        version         = "1"
        run_order       = 3
        configuration = {}
        region          = "us-east-1"
      }
    }
  }

  stage {
    name = "Post-Deploy"
    dynamic "action" {
      for_each = var.post_codebuild_projects
      content {
        name            = action.value
        category        = "Build"
        owner           = "AWS"
        provider        = "CodeBuild"
        input_artifacts = ["source_output"]
        version         = "1"

        configuration = {
          ProjectName = action.value
        }

      }

    }
  }

}

resource "aws_iam_role" "codepipeline_role" {
  name               = "role-${local.codepipeline_name}"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role_policy.json
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "policy-${local.codepipeline_name}"
  role   = aws_iam_role.codepipeline_role.id
  policy = data.aws_iam_policy_document.codepipeline_role_policy.json
}

