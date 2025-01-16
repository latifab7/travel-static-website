terraform {
  backend "s3" {        # tfstate file backup via S3 bucket
    bucket = "terraform-tfstate-stockage"
    key = "key/production/terraform.tfstate"
    region = var.region
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}
