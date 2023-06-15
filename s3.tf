##### target_bucket #####

data "aws_s3_bucket" "target_bucket"{
  bucket = var.target_bucket
}

resource "aws_s3_bucket_ownership_controls" "target_bucket_oc" {
  bucket = data.aws_s3_bucket.target_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

##### src_bucket #####

data "aws_s3_bucket" "src_bucket"{
  bucket = var.src_bucket
}

resource "aws_s3_bucket_ownership_controls" "src_bucket_oc" {
  for_each = var.env_type == "non-prod" ? {"env_type":"non-prod"} : {}
  bucket = data.aws_s3_bucket.src_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

##### test_bucket #####

data "aws_s3_bucket" "test_bucket"{
  bucket = var.test_bucket
}

resource "aws_s3_bucket_ownership_controls" "test_bucket_oc" {
  bucket = data.aws_s3_bucket.test_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}