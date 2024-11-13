
# create a s3 bucket 
resource "aws_s3_bucket" "travel_website" {
    bucket = "latifa-travel-website"
    tags = {
        environement = "dev"
    }
  
}

# define s3 public access block and attach it to our target s3 bucket
resource "aws_s3_bucket_public_access_block" "travel_website" {
    bucket = aws_s3_bucket.travel_website.bucket  
    block_public_acls = true 
    block_public_policy = true 
    ignore_public_acls = true                   # deny public access to our s3 ( only cloudfront)
    restrict_public_buckets = true
}


# define s3 encryption settings and attach it to our target S3 bucket 
resource "aws_s3_bucket_server_side_encryption_configuration" "travel_website" {
    bucket = aws_s3_bucket.travel_website.bucket 
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  
}

# define s3 versioning setting and attach it to our target s3 bucket 
resource "aws_s3_bucket_versioning" "travel_website" {
    bucket = aws_s3_bucket.travel_website.bucket 
    versioning_configuration {
      status = "Disabled"
    }
  
}


# create cloudfront CDN


# first create the OAC 
resource "aws_cloudfront_origin_access_control" "travel_website" {
    name = "latifa_travel_website"
    origin_access_control_origin_type = "s3"
    signing_protocol = "sigv4"
    signing_behavior = "always"
}



resource "aws_cloudfront_distribution" "travel_website" {
  depends_on = [ aws_s3_bucket.travel_website, aws_cloudfront_origin_access_control.travel_website ]
  origin {
    domain_name              = aws_s3_bucket.travel_website.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.travel_website.id
    origin_id                = aws_s3_bucket.travel_website.id
  }

  enabled             = true
  comment             = "Some comment"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.travel_website.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "https-only"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "blacklist"
      locations        = ["JP", "GB", "DE"]
    }
  }

  tags = {
    Environment = "DEV"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}


# create iam policy to allow cloudfront to fetch data from s3
data "aws_iam_policy_document" "allow_cloudfront" {
  depends_on = [ aws_cloudfront_distribution.travel_website ]
  statement {
    sid = "1"
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]

    principals {
      identifiers = ["cloudfront.amazonaws.com" ]   # whom the statement apply to 
      type = "Service"
    }

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.travel_website.bucket}/*"
    ]

    condition {
      test = "StringEquals"
      variable = "AWS:SourceArn"
      values = [aws_cloudfront_distribution.travel_website.arn]
    }
  }

}

resource "aws_s3_bucket_policy" "allow_cloudfront" {
    bucket = aws_s3_bucket.travel_website.id 
    policy = data.aws_iam_policy_document.allow_cloudfront.id
}

# <ErrorResponse xmlns="http://cloudfront.amazonaws.com/doc/2020-05-31/"><Error><Type>Receiver</Type><Code>ServiceUnavailable</Code><Message>CloudFront encountered an internal error. Please try again.</Message></Error><RequestId>d7436c08-c79a-4b8b-8504-339afdf95e41</RequestId></ErrorResponse>
#    http.response.header.content_type=text/xml http.response.header.x_amzn_requestid=d7436c08-c79a-4b8b-8504-339afdf95e41 tf_aws.signing_region="" tf_req_id=09942ee6-d6bb-3bc4-cc87-6f5776da52fc http.status_code=503 rpc.method=CreateDistributionWithTags rpc.service=CloudFront @caller=github.com/hashicorp/aws-sdk-go-base/v2@v2.0.0-beta.59/logging/tf_logger.go:45 @module=aws aws.region=eu-west-3 http.response.header.date="Wed, 13 Nov 2024 16:06:27 GMT" rpc.system=aws-api tf_provider_addr=registry.terraform.io/hashicorp/aws tf_rpc=ApplyResourceChange timestamp="2024-11-13T17:06:27.601+0100"
