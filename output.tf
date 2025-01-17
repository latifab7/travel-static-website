output "cloudfront_domain_name" {
    description = "cloud front distribution domain name"
    value = aws_cloudfront_distribution.travel_website.domain_name
}