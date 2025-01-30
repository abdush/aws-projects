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

output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.website_cf.domain_name
}

# Outputs for domain
output "registered_domain" {
  description = "The registered domain name"
  value       =  aws_route53_zone.website_zone.name
}

output "hosted_zone_id" {
  description = "The ID of the hosted zone created in Route 53"
  value       = aws_route53_zone.website_zone.zone_id
}

# Output the nameservers for updating in Namecheap
output "route53_nameservers" {
  description = "Route 53 nameservers for your domain"
  value       = aws_route53_zone.website_zone.name_servers
}