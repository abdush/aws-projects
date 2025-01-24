output "s3_bucket_name" {
  value = aws_s3_bucket.website_bucket.id
}

output "s3_bucket_regional_domain" {
  value = aws_s3_bucket.website_bucket.bucket_regional_domain_name
}

output "website_domain" {
  description = "The domain name of the website"
  value       = aws_s3_bucket_website_configuration.website_config.website_domain
}

output "website_endpoint" {
  description = "The endpoint of the S3 bucket for static website hosting"
  value       = aws_s3_bucket_website_configuration.website_config.website_endpoint
}

# output "cloudfront_domain_name" {
#   value = aws_cloudfront_distribution.website_cdn.domain_name
# }

# output "route53_zone_id" {
#   value = aws_route53_zone.website_zone.zone_id
# }
