##### target_bucket #####

data aws_s3_bucket target_bucket{
  bucket = var.target_bucket
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

resource "aws_s3_bucket_public_access_block" "target_bucket_ab" {
  bucket                  = data.aws_s3_bucket.target_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "target_bucket_policy" {
  bucket = data.aws_s3_bucket.target_bucket.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
          "AWS": [
            "arn:aws:iam::${data.aws_caller_identity.prod.account_id}:root",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          ],
          "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "s3:*",
      "Resource":[ 
        "arn:aws:s3:::${data.aws_s3_bucket.target_bucket.id}/*",
        "arn:aws:s3:::${data.aws_s3_bucket.target_bucket.id}"
      ]
    }
  ]
}
POLICY
}

##### src_bucket #####

data aws_s3_bucket src_bucket{
  bucket = var.src_bucket
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

resource "aws_s3_bucket_public_access_block" "src_bucket_ab" {
  bucket                  = data.aws_s3_bucket.src_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "src_bucket_policy" {
  bucket = data.aws_s3_bucket.src_bucket.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
          "AWS": [
            "arn:aws:iam::${data.aws_caller_identity.prod.account_id}:root",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          ],
          "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "s3:*",
      "Resource":[
        "arn:aws:s3:::${data.aws_s3_bucket.src_bucket.id}/*",
        "arn:aws:s3:::${data.aws_s3_bucket.src_bucket.id}"
      ]
    }
  ]
}
POLICY
}

##### test_bucket #####

data aws_s3_bucket test_bucket{
  bucket = var.test_bucket
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

resource "aws_s3_bucket_public_access_block" "test_bucket_ab" {
  bucket                  = data.aws_s3_bucket.test_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "test_bucket_policy" {
  bucket = data.aws_s3_bucket.test_bucket.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
          "AWS": [
            "arn:aws:iam::${data.aws_caller_identity.prod.account_id}:root",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          ],
          "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "s3:*",
      "Resource":[
        "arn:aws:s3:::${data.aws_s3_bucket.test_bucket.id}/*",
        "arn:aws:s3:::${data.aws_s3_bucket.test_bucket.id}"
      ]
    }
  ]
}
POLICY
}