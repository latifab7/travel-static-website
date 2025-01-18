output "cloudfront_domain_name" {
    description = "cloud front distribution domain name"
    value = aws_cloudfront_distribution.travel_website.domain_name
}

output "cloudfront_Id" {
    description = "cloudfront Id for monitoring attachement"
    value = aws_cloudfront_distribution.travel_website.id
}

output "travel_bucket_name" {
    description = "value"
    value = aws_s3_bucket.travel_website.bucket
}

