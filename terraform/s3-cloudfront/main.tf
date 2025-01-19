#####################################
# S3
#####################################


# create a s3 bucket 
resource "aws_s3_bucket" "travel_website" {
    bucket = var.bucket_name
    tags = {
        environement = var.environement
    }
}

# define s3 public access block and attach it to our target s3 bucket
resource "aws_s3_bucket_public_access_block" "travel_website" {
    bucket = aws_s3_bucket.travel_website.bucket  
    block_public_acls = true 
    block_public_policy = true 
    ignore_public_acls = true                   # deny public access to our s3 
    restrict_public_buckets = true
}


# define s3 encryption settings and attach it to our target S3 bucket 
resource "aws_s3_bucket_server_side_encryption_configuration" "travel_website" {
    bucket = aws_s3_bucket.travel_website.bucket 
    rule {
      apply_server_side_encryption_by_default {     #encryptiona at rest
        sse_algorithm = "AES256"
      }
    } 
}

# define s3 versioning setting and attach it to our target s3 bucket 
resource "aws_s3_bucket_versioning" "travel_website" {
    bucket = aws_s3_bucket.travel_website.bucket 
    versioning_configuration {                # enable for better security and preservation of data
      status = "Disabled"
    }
}


#####################################
# CLOUD FRONT 
#####################################

# first create the OAC 
resource "aws_cloudfront_origin_access_control" "travel_website" {
    name = "latifa_travel_website"
    origin_access_control_origin_type = "s3"
    signing_protocol = "sigv4"
    signing_behavior = "always"
}


# create the cloudfront distribution
resource "aws_cloudfront_distribution" "travel_website" {
  depends_on = [ aws_s3_bucket.travel_website, aws_cloudfront_origin_access_control.travel_website ]
  origin {
    domain_name              = aws_s3_bucket.travel_website.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.travel_website.id
    origin_id                = aws_s3_bucket.travel_website.id
  }

  enabled             = true
  comment             = "Travel Website CDN"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.travel_website.id

    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6" # AWS Managed Caching Policy

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  aliases = var.cloudfront_aliases  # domain name associated 

  restrictions {
    geo_restriction {
     restriction_type = "blacklist"
     locations        = ["NP", "MC"]
    }
  }

  tags = {
    Environment = var.environement
  }

  viewer_certificate {
   # cloudfront_default_certificate = true
   acm_certificate_arn = var.acm_certificate 
   ssl_support_method = "sni-only"
   minimum_protocol_version = "TLSv1.2_2021"
  }
}

############################################
# IAM POLICY - ALLOW CLOUFRONT TO ACCESS S3
############################################

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
    policy = data.aws_iam_policy_document.allow_cloudfront.json #policy needs to be in json format
}

