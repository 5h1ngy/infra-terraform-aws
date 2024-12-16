data "aws_route53_zone" "avatar_maker_click" {
  name         = "avatar-maker.click"
  private_zone = false
}

resource "aws_route53_record" "avatar_maker_click" {
  zone_id = data.aws_route53_zone.avatar_maker_click.zone_id
  name    = "avatar-maker.click" # Corretto
  type    = "A"
  ttl     = 300
  records = [module.compute.frontend_public_ip]
}

resource "aws_route53_record" "www_avatar_maker_click" {
  zone_id = data.aws_route53_zone.avatar_maker_click.zone_id
  name    = "www.avatar-maker.click"
  type    = "A"
  ttl     = 300
  records = [module.compute.frontend_public_ip]
}

