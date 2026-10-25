resource "aws_route53_zone" "fishybowl_social" {
  name    = "fishybowl.social"
  comment = "HostedZone created by Route53 Registrar"
}

resource "aws_route53_record" "fishybowl_social_a" {
  zone_id = aws_route53_zone.fishybowl_social.zone_id
  name    = "fishybowl.social"
  type    = "A"
  ttl     = 300
  records = ["44.203.242.160"]
}

import {
  to = aws_route53_zone.fishybowl_social
  id = "Z085297434OU8TICI41US"
}

import {
  to = aws_route53_record.fishybowl_social_a
  id = "Z085297434OU8TICI41US_fishybowl.social_A"
}
