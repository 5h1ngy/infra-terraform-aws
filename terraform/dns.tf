data "aws_route53_zone" "domain_click" {
  name         = "5h1ngy.click"
  private_zone = false
}

# resource "aws_route53_zone" "domain_click" {
#   name = "5h1ngy.click"
# }

resource "aws_route53_record" "domain_click" {
  # zone_id = aws_route53_zone.domain_click.zone_id
  zone_id = data.aws_route53_zone.domain_click.zone_id
  name    = "5h1ngy.click" # Corretto
  type    = "A"
  ttl     = 300
  records = [aws_instance.frontend.public_ip]
}

resource "aws_route53_record" "www_domain_click" {
  # zone_id = aws_route53_zone.domain_click.zone_id
  zone_id = data.aws_route53_zone.domain_click.zone_id
  name    = "www.5h1ngy.click"
  type    = "A"
  ttl     = 300
  records = [aws_instance.frontend.public_ip]
}

