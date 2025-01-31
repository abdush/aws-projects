# Create a hosted zone for the domain
resource "aws_route53_zone" "website_zone" {
  name = var.domain_name

  tags = {
    Name        = "Resume website"
    Environment = "Dev"
  }
}

# Create DNS records for CloudFront
resource "aws_route53_record" "cf_alias" {
  zone_id = aws_route53_zone.website_zone.zone_id
  name    =  aws_route53_zone.website_zone.name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website_cf.domain_name
    zone_id                = aws_cloudfront_distribution.website_cf.hosted_zone_id
    evaluate_target_health = false
  }
}

# Create DNS records for CloudFront from the resume subdomain
resource "aws_route53_record" "cf_alias_subdomain" {
  zone_id = aws_route53_zone.website_zone.zone_id
  name    =  "resume"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website_cf.domain_name
    zone_id                = aws_cloudfront_distribution.website_cf.hosted_zone_id
    evaluate_target_health = false
  }
}

# Apply same for IPv6 if enabled in cloudfront
# Create DNS records for CloudFront
resource "aws_route53_record" "cf_alias_ipv6" {
  zone_id = aws_route53_zone.website_zone.zone_id
  name    =  aws_route53_zone.website_zone.name
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.website_cf.domain_name
    zone_id                = aws_cloudfront_distribution.website_cf.hosted_zone_id
    evaluate_target_health = false
  }
}

# Create DNS records for CloudFront from the resume subdomain
resource "aws_route53_record" "cf_alias_subdomain_ipv6" {
  zone_id = aws_route53_zone.website_zone.zone_id
  name    =  "resume"
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.website_cf.domain_name
    zone_id                = aws_cloudfront_distribution.website_cf.hosted_zone_id
    evaluate_target_health = false
  }
}