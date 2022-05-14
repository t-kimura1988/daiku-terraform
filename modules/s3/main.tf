variable "bucket_name" {}

resource "aws_s3_bucket" "log" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_lifecycle_configuration" "example" {
  bucket = aws_s3_bucket.log.id

  rule {
    id = "log"

    expiration {
      days = 90
    }


    filter {
      and {
        prefix = "log/"

        tags = {
          rule      = "log"
          autoclean = "true"
        }
      }
    }

    status = "Enabled"
  }

}

resource "aws_s3_bucket_policy" "log" {
  bucket = aws_s3_bucket.log.id
  policy = data.aws_iam_policy_document.log.json
}

output "bucket_id" {
  value = aws_s3_bucket.log.id
}

data "aws_iam_policy_document" "log" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.log.id}/*"]

    principals {
      type        = "AWS"
      identifiers = ["582318560864"]
    }
  }
}