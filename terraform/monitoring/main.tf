#####################################
# SIMPLE NOTIFICATION SERVICE
#####################################


# default region
resource "aws_sns_topic" "sns_s3" {
  name = var.sns_s3_alert
}

resource "aws_sns_topic_subscription" "sns_default_region" {
  protocol = "email"
  topic_arn = aws_sns_topic.sns_s3.arn
  endpoint = var.email
}


# Us virgina region for cloudfront alert 
resource "aws_sns_topic" "sns_cloudfront" {
  provider = aws.us-east-1   # uses US region
  name = var.sns_cloudfront_alert
}

resource "aws_sns_topic_subscription" "sns_virginia_region" {
  protocol = "email"
  topic_arn = aws_sns_topic.sns_cloudfront.arn
  endpoint = var.email
}


########################################################
# CLOUDWATCH ALARMS - CLOUDFRONT - CREATE IN US-EAST-1
########################################################

# Alarm to be triggered if Error Rate exceed 20 within 5 min
resource "aws_cloudwatch_metric_alarm" "client_error" {
  provider                  = aws.us-east-1
  alarm_name                = "cloudfront_client_error"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "4xxErrorRate"
  namespace                 = "AWS/CloudFront"
  period                    = 300  # Check every 5 minutes
  statistic                 = "Average"
  threshold                 = 20
  alarm_description         = "This metrics mesure the client side error not found or bad request"

  dimensions = {
    DistributionId = var.cloudfront_id
  } 

  alarm_actions = [aws_sns_topic.sns_cloudfront.arn]
}


# Alarm to be triggered is the total request per day exceed 100 000 request
resource "aws_cloudwatch_metric_alarm" "cloudfront_requests_alarm_daily" {
  provider            = aws.us-east-1
  alarm_name          = "CloudFront-Requests-Daily"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Requests"
  namespace           = "AWS/CloudFront"
  period              = 86400  # 1 day
  statistic           = "Sum"
  threshold           = 100000 # ~100 000 requests per day / 24 hours

  dimensions = {
    DistributionId = var.cloudfront_id
  }

  alarm_actions = [aws_sns_topic.sns_cloudfront.arn] 
}


#####################################
# CLOUDWATCH ALARMS - S3
#####################################

# Alarm to be triggered when Object number exceed 400 - Once a day
resource "aws_cloudwatch_metric_alarm" "bucket_object_alarm" {
  alarm_name                = "bucket_object_alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "NumberOfObjects"
  namespace                 = "AWS/S3"
  period                    = 86400 # Check once per day
  statistic                 = "Sum"
  threshold                 = 400 
  alarm_description         = "This metrics mesure the numeber of object in our bucket"

  dimensions = {
    BucketName = var.travel_bucket_name
    StorageType = "AllStorageTypes"
  } 

  alarm_actions = [aws_sns_topic.sns_s3.arn]
}

# Alarm to be triggered when Bucket total size exceed 4GB - Once a day
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

  alarm_actions = [aws_sns_topic.sns_s3.arn]
}