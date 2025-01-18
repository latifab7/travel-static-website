module "static_website" {
    source = "./s3-cloudfront"
  
}

module "monitoring" {
  source = "./monitoring"
  cloudfront_id = module.static_website.cloudfront_Id
  travel_bucket_name = module.static_website.travel_bucket_name
}