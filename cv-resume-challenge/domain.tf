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