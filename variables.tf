variable "environement" {
    description = "the type of environment"
    type = string 
    default = "prod"
}

variable "region" {
    description = "aws region"
    type = string 
    default = "eu-west-3"
}

variable "bucket_name" {
    description = "bucket name"
    type = string
    default = "latifa-travel-website"
  
}