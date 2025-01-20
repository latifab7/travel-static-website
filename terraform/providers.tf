terraform {
  backend "s3" {        # tfstate file backup via S3 bucket
    bucket = "tf-tfstate-stockage"
    key = "key/production/terraform.tfstate"
    region = "eu-west-3"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Default AWS Provider
provider "aws" {
  region = "eu-west-3"
}

# Provider for Cloudwatch Alarms and SNS 
provider "aws" {
  alias = "us-east-1"
  region = "us-east-1"
}
