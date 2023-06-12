##### artifacts_bucket #####

data aws_s3_bucket codepipeline_bucket{
  bucket = local.artifacts_bucket_name
}

resource "aws_s3_bucket_ownership_controls" "codepipeline_bucket_oc" {
  bucket = data.aws_s3_bucket.codepipeline_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "codepipeline_bucket_acl" {
  bucket = data.aws_s3_bucket.codepipeline_bucket.id
  acl    = "private"
}

##### target_bucket #####

data aws_s3_bucket target_bucket{
  id = var.target_bucket
}

resource "aws_s3_bucket_ownership_controls" "target_bucket_oc" {
  bucket = data.aws_s3_bucket.target_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "target_bucket_acl" {
  bucket = data.aws_s3_bucket.target_bucket.id
  acl    = "private"
}

##### src_bucket #####

data aws_s3_bucket src_bucket{
  id = var.src_bucket
}

resource "aws_s3_bucket_ownership_controls" "src_bucket_oc" {
  bucket = data.aws_s3_bucket.src_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "src_bucket_acl" {
  bucket = data.aws_s3_bucket.src_bucket.id
  acl    = "private"
}

##### test_bucket #####

data aws_s3_bucket test_bucket{
  id = var.test_bucket
}

resource "aws_s3_bucket_ownership_controls" "test_bucket_oc" {
  bucket = data.aws_s3_bucket.test_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "test_bucket_acl" {
  bucket = data.aws_s3_bucket.test_bucket.id
  acl    = "private"
}