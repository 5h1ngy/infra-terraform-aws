data "aws_route53_zone" "domain" {
  name = "5h1ngy.click"
}

resource "aws_route53_record" "domain" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "5h1ngy.click"
  type    = "A"
  ttl     = 300
  records = [aws_instance.frontend.public_ip]
}

resource "aws_route53_record" "www_domain" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "www.5h1ngy.click"
  type    = "A"
  ttl     = 300
  records = [aws_instance.frontend.public_ip]
}