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
    default = "arn:aws:acm:us-east-1:339713098679:certificate/17679843-981c-42d2-b1a0-dd5601e024b5"
}

variable "cloudfront_aliases" {
    description = "domain name passed in aliases"
    type = list(string)
    default = ["www.istla.online"]
}

