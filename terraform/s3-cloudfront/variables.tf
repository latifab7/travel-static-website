variable "environement" {
    description = "the type of environment"
    type = string 
    default = "prod"
}

variable "bucket_name" {
    description = "bucket name"
    type = string
    default = "latifa-travel-website" 
}

variable "acm_certificate" {
    description = "ssl certificate if for domain name"
    type = string
    default = "arn:aws:acm:us-east-1:061051253558:certificate/31cfa002-ed44-4c90-bd2e-190e0e054367"
}

variable "cloudfront_aliases" {
    description = "domain name passed in aliases"
    type = list(string)
    default = ["www.istla.online"]
}

