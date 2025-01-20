variable "email" {
    description = "email for simple notification service"
    type = string
    default = "latifaboulil@hotmail.fr"
}

variable "cloudfront_id" {
    description = "cloudfront_id for cloudwatch resource"
    type = string
}

variable "travel_bucket_name" {
    description = "travel bucket name for cloudwatch resource"
    type = string
}

variable "sns_s3_alert" {
    type = string
    default = "travelwebsite-s3-alert"
}

variable "sns_cloudfront_alert" {
    type = string
    default = "travelwebsite-cloudfront-alert"
  
}