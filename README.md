# Personal Travel and Photography Website

This project showcases my travel experiences and photography portfolio through a static website hosted securely on AWS. It demonstrates my ability to work with cloud infrastructure, DevOps practices, and automation tools to deliver a fully functional, secure, and globally accessible website.

## Table of Contents

- Overview
- Tech Stack
- Architecture
- Project Structure
- Setup Instructions
- Deployment
- Monitoring
- Troubleshooting
- Cost Optimization
- License

## Overview

This is a personal project where I share my photography and travel experiences. The website is hosted securely on AWS using various services like S3, CloudFront, ACM, and CloudWatch. The goal of this project is to showcase my technical skills in deploying and managing cloud infrastructure while also displaying my personal photography work.

Note: The website's assets (HTML, CSS, images) are not included in this repository for privacy and security reasons. These assets are uploaded to AWS S3 as part of the live deployment.

![website](assests/websitehomepage.png)

## Tech Stack

- Frontend: HTML, CSS
- Cloud: AWS (S3, CloudFront, ACM, CloudWatch)
- Infrastructure as Code: Terraform
- CI/CD: GitLab CI/CD
- Monitoring and Alerts: AWS CloudWatch, SNS
- Domain: Managed via OVHCloud

## Architecture

- S3: The website files are stored in a private S3 bucket, only accessible through CloudFront.
- CloudFront: Serves the content globally with HTTPS enforcement via SSL/TLS (ACM). It also has    geo-restrictions set to control access.
- Terraform: Infrastructure is defined as code using Terraform, enabling easy deployment and management.
- GitLab CI/CD: Automates file transfers to S3 whenever there's a change in the repository.
- CloudWatch: Monitors the AWS resources and sends alerts for 4xx errors, bucket size, HTTP requests.

![diagrams](assests/diagram.png)

## Project Structure

- Public/ : website repository containing all the html/css and images files
- Terraform/: Contains all the Terraform files to manage AWS infrastructure devided into 2 modules 
    - main.tf: The main Terraform configuration file for the infrastructure setup.
    - variables.tf: Input variables for customization.
    - output.tf: Outputs the values for the created resources.
- .gitlab-ci.yml: GitLab CI/CD configuration for automating the deployment of the static website to AWS S3.
- README.md: This file.
- assests/: Contains all the screenshots related to this project

Note: The public/ folder, which contains the website assets (HTML, CSS, images), is excluded from this repository for security and privacy reasons.

## About CloudFront: High Availability and Low Latency
Amazon CloudFront is a global content delivery network (CDN) service that enhances the availability and performance of your website. It achieves this through:

- High Availability:
CloudFront leverages a global network of edge locations to ensure content is always delivered, even during high traffic or regional outages.
- Low Latency:
By caching content at edge locations close to users, CloudFront significantly reduces latency, ensuring faster load times and a better user experience.

- Performance Comparison: Without CloudFront vs. With CloudFront
Below is a side-by-side comparison of DNS propagation times and website latency, illustrating the performance improvement when using CloudFront:

| Without CloudFront               | With CloudFront                 |
|----------------------------------|---------------------------------|
| ![Without CloudFront](assests/withoutcloudfront.png) | ![With CloudFront](assests/withcloudfront.png) |


## Setup Instructions
To deploy the infrastructure and website, follow these steps:

### Prerequisites
Ensure you have the following:

An AWS account with access to S3, CloudFront, ACM, and CloudWatch.
Terraform installed (version 5.0 or higher).
A GitLab account for CI/CD setup.
A domain name registered (through Route 53 or an external provider).

### Deployment Steps
1. Clone the Repository
Clone the project repository to your local machine and navigate into it:
```bash
git clone https://github.com/latifab7/travel-static-website.git
cd travel-static-website
```

2. Manually Request an ACM Certificate
Request an ACM certificate in the AWS Management Console:

    1. Navigate to the Certificate Manager (ACM) service.
    2. Request a public certificate for your domain name.
    3. Approve the certificate through your domain name provider (Route 53 or an external provider).

3. Configure AWS Credentials
Ensure your AWS credentials are configured properly via the AWS CLI or environment variables in GitLab CI/CD:

```bash
aws configure
```

4. Update Variables
Modify the necessary variables.tf files in the repository to reflect your specific setup:

- Update monitoring/variables.tf to include your email address.
- Update all values in s3-cloudfront/variables.tf to match your configuration.

5. Initialize Terraform
Prepare Terraform by initializing the working directory:
```bash
terraform init
```

6. Apply the Terraform Configuration
Deploy the AWS infrastructure by applying the Terraform configuration:
```bash
terraform apply
```

This will create the necessary AWS resources, including S3, CloudFront, and monitoring configurations.

7. Update Your Domain Name Records
In your domain name provider's settings (e.g., Route 53 or an external provider), manually create a DNS record to map your custom domain name to the CloudFront domain name provided by Terraform.

![domain](assests/ovhrecord.png)

8. Upload your website in S3
Once your infrastructure is ready, upload your website files to the S3 bucket with the following command:
```bash
aws s3 sync local/path/to/website s3://your-s3-bucket-name/
```
This will sync the files from your local directory to the S3 bucket, making your website accessible online.

9. Automated deployment with Gitlab CI/CD
For a fully automated deployment process, you can set up GitLab CI/CD to deploy both the infrastructure and the website. Configure your GitLab pipeline to automatically sync updates to the S3 bucket. For pipeline setup details, refer to the .gitlab-ci.yml file in the repository.

## Deployment

The website is deployed using the GitLab CI/CD pipeline. Whenever changes are made to the repository, the pipeline will automatically upload updated content to the S3 bucket.

1. Changes to the website (HTML/CSS) are pushed to the GitLab repository.
2. The GitLab pipeline triggers and uploads the changes to S3.
3. CloudFront serves the updated content globally.

Note: The content in the public/ folder, including images, is not part of this repository and should be uploaded to S3 separately. This can be done via GitLab CI/CD or manually.

## Monitoring
This project integrates AWS CloudWatch for resource monitoring. Key metrics like HTTP requests, 4xx errors, and S3 bucket usage are tracked. Alarms are configured to notify via SNS for important events.

1. 4xx errors: If there is an increase in client errors.
2. Bucket size: To monitor if the website's storage usage exceeds a set limit.
3. HTTP requests: To track the number of requests served by CloudFront.

## Troubleshooting

### Issue:
CloudWatch alarms for CloudFront metrics were created in the eu-west-3 region. While the creation of the alarms succeeded, no data was fetched for over a day unlike S3 alerts.

![error](assests/cloudwatcherror.png)

### Investigation:
Upon further investigation, I discovered that CloudWatch alarms for CloudFront metrics can only be created and accessed in the us-east-1 region. This is because CloudFront's metrics are only available in the us-east-1 region, even though CloudWatch can be configured in other regions.

### Solution:
To resolve this issue,the following changes to our Terraform configuration was made:

- Added a new provider configuration for us-east-1: A new provider alias for the us region was introduced in our Terraform configuration.
- Created a new SNS topic in us-east-1: Since SNS topics are region-specific, I created a separate SNS topic in us-east-1 for receiving email alerts related to CloudFront alarms.
- Reconfigured CloudWatch alarms to use the us-east-1 provider: I updated the CloudWatch alarm resources for CloudFront metrics to use the newly created us-east-1 provider.
- Kept the rest of the configuration in eu-west-3: The rest of our resources, including those for S3 and other services, remained in the eu-west-3 region.

![terraform](assests/cloudwatch.png)
![results](assests/console.png)


## Cost Optimization
To keep the project within the AWS Free Tier limits, we have optimized resources as follows:

- CloudWatch Alarms and Metrics:
    - We utilize the 5 free alarms and select metrics available in CloudWatch.
    - Alarms are configured to trigger notifications via SNS email instead of SMS to avoid additional costs.

- Security Features:
    - We remain within the Free Tier limits by using:
        - SSL certificates from ACM.
        - Metadata management, carefully scoped IAM policies, and private S3 buckets.
        - Geo-restrictions and optimized CloudFront caching for security and performance.
    - We deliberately avoid using AWS WAF or Shield to enhance security further, as they are not included in the Free Tier.

- Free Tier Maximization:
    - All free-tier limits are utilized to their maximum extent without exceeding them, ensuring minimal costs for the project.

This approach ensures efficient cost management while maintaining a secure and functional infrastructure.


![website](assests/page.png)

## License
This project is licensed under the MIT License – see the LICENSE file for details.

