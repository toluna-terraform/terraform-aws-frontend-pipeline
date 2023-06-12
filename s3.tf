data aws_s3_bucket codepipeline_bucket{
  name = local.artifacts_bucket_name
}

resource "aws_s3_bucket_ownership_controls" "source_codebuild_bucket" {
  bucket = data.aws_s3_bucket.codepipeline_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "source_codebuild_bucket" {
  bucket = data.aws_s3_bucket.codepipeline_bucket.id
  acl    = "private"
  depends_on = [
    aws_s3_bucket.codepipeline_bucket, aws_s3_bucket_versioning.codepipeline_bucket,aws_s3_bucket_ownership_controls.source_codebuild_bucket
  ]
}
