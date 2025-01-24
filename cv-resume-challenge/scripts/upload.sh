#!/bin/bash

# Variables
BUCKET_NAME="ahussein-resume.com"  # Replace with your S3 bucket name
FILE_PATH="../website/index.html"  # Replace with the path to your index.html
AWS_PROFILE="terraform"  # Replace with your AWS Vault profile

# Upload the file to S3
aws-vault exec "$AWS_PROFILE" -- aws s3 cp "$FILE_PATH" "s3://$BUCKET_NAME/" \
  #--acl public-read \
  --content-type "text/html"

# Output the website URL
echo "File uploaded successfully!"
echo "You can access your website at: http://$BUCKET_NAME.s3-website-eu-west-2.amazonaws.com"
