resource "aws_route53_zone" "teenytanks_social" {
  name    = "teenytanks.social"
  comment = "HostedZone created by Route53 Registrar"
}

resource "aws_route53_record" "teenytanks_social_a" {
  zone_id = aws_route53_zone.teenytanks_social.zone_id
  name    = "teenytanks.social"
  type    = "A"
  ttl     = 300
  records = ["54.196.95.235"]
}

import {
  to = aws_route53_zone.teenytanks_social
  id = "Z01870773NH7OPZ866F8P"
}

import {
  to = aws_route53_record.teenytanks_social_a
  id = "Z01870773NH7OPZ866F8P_teenytanks.social_A"
}
