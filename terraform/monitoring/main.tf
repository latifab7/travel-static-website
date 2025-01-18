#####################################
# SIMPLE NOTIFICATION SERVICE
#####################################

resource "aws_sns_topic" "sns-travel-website" {
  name = "latifa-travel-website"
}

resource "aws_sns_topic_subscription" "name" {
  protocol = "email"
  topic_arn = aws_sns_topic.sns-travel-website.arn
  endpoint = var.email
}

#####################################
# CLOUDWATCH ALARMS - CLOUDFRONT 
#####################################

# cloudwatch alarm set for cloudfront 4xxError Rate ( client side error)
resource "aws_cloudwatch_metric_alarm" "client_error" {
  alarm_name                = "cloudfront_client_error"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "4xxErrorRate"
  namespace                 = "AWS/CloudFront"
  period                    = 300  # Check every 5 minutes
  statistic                 = "Average"
  threshold                 = 1.00
  alarm_description         = "This metrics mesure the client side error not found or bad request"

  dimensions = {
    DistributionId = var.cloudfront_id
  } 

  alarm_actions = [aws_sns_topic.sns-travel-website.arn]
}


# add cloudwatch alaram for 5xxErrorRate if the website has a backend server

# CloudWatch Alarm for CloudFront Requests at 8,000,000 Requests Threshold
resource "aws_cloudwatch_metric_alarm" "cloudfront_requests_alarm" {
  alarm_name          = "CloudFront-Requests-8M"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Requests"
  namespace           = "AWS/CloudFront"
  period              = 86400 
  statistic           = "Sum"
  threshold           = 8000000 # 8,000,000 requests threshold

  dimensions = {
    DistributionId = var.cloudfront_id # Replace with your CloudFront distribution ID
  }

  alarm_actions = [aws_sns_topic.sns-travel-website.arn]
}


# cloudwatch alarm set for S3 bucket size
resource "aws_cloudwatch_metric_alarm" "bucket_size_alarm" {
  alarm_name                = "bucket_size_alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "BucketSizeBytes"
  namespace                 = "AWS/S3"
  period                    = 86400 # Check once per day
  statistic                 = "Average"
  threshold                 = 4000000000 # 5 GB threshold for bucket size ( free tiers limit = 5)
  alarm_description         = "This metrics mesure the size of the project bucket"

  dimensions = {
    BucketName = var.travel_bucket_name
    StorageType = "StandardStorage"
  } 

  alarm_actions = [aws_sns_topic.sns-travel-website.arn]
}

#####################################
# CLOUDWATCH ALARMS - S3
#####################################

# cloudwatch alarm set for S3 object count
resource "aws_cloudwatch_metric_alarm" "bucket_object_alarm" {
  alarm_name                = "bucket_object_alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "NumberOfObjects"
  namespace                 = "AWS/S3"
  period                    = 86400 # Check once per day
  statistic                 = "Average"
  threshold                 = 1000 # 1000 objects threshold (adjust as needed) 
  alarm_description         = "This metrics mesure the numeber of object in our bucket"

  dimensions = {
    BucketName = var.travel_bucket_name
    StorageType = "AllStorageTypes"
  } 

  alarm_actions = [aws_sns_topic.sns-travel-website.arn]
}

