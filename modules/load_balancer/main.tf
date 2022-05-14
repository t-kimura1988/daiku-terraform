
variable "subnet_ids" {
  type = list(string)
}
variable "security_group_ids" {
  type = list(string)
}
variable "bucket_id" {}
variable "enable_deletion_protection" {}
variable "vpc_id" {}
variable "app_lb" {}
variable "route53_zone_name" {}

resource "aws_lb" "main" {
  for_each                   = var.app_lb
  name                       = each.value.app_lb_name
  load_balancer_type         = "application"
  internal                   = false
  idle_timeout               = 60
  enable_deletion_protection = var.enable_deletion_protection

  subnets = var.subnet_ids

  security_groups = var.security_group_ids

  access_logs {
    bucket  = var.bucket_id
    enabled = true
  }
}

data "aws_route53_zone" "main" {
  name = var.route53_zone_name
}

resource "aws_route53_record" "main" {
  for_each = aws_lb.main
  zone_id  = data.aws_route53_zone.main.zone_id
  name     = "${each.key}.${data.aws_route53_zone.main.name}"

  type = "A"

  alias {
    name                   = each.value.dns_name
    zone_id                = each.value.zone_id
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate" "main" {
  domain_name = "*.${var.route53_zone_name}"
  subject_alternative_names = [

  ]
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "main_certificate" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  name    = each.value.name
  records = [each.value.record]
  type    = each.value.type
  zone_id = data.aws_route53_zone.main.zone_id
  ttl     = 60
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in aws_route53_record.main_certificate : record.fqdn]
}



resource "aws_lb_listener" "http" {

  for_each = var.app_lb

  load_balancer_arn = aws_lb.main[each.key].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port = 443
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {

  for_each = var.app_lb

  load_balancer_arn = aws_lb.main[each.key].arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.main.arn
  ssl_policy        = "ELBSecurityPolicy-FS-1-2-Res-2019-08"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "THIS IS HTTPS!!!"
      status_code  = "200"
    }
  }

  depends_on = [
    aws_acm_certificate_validation.main
  ]
}

resource "aws_lb_listener_rule" "main" {
  for_each = var.app_lb

  listener_arn = aws_lb_listener.https[each.key].arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[each.key].arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_lb_target_group" "main" {

  for_each = var.app_lb

  name                 = each.value.alb_target_group_name
  target_type          = "ip"
  vpc_id               = var.vpc_id
  port                 = 8080
  protocol             = "HTTP"
  deregistration_delay = 30

  health_check {
    path                = "/actuator/health"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = 200
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  depends_on = [
    aws_lb.main
  ]

  lifecycle {
    ignore_changes = [
      deregistration_delay
    ]
  }
}

output "aws_lb" {
  value = aws_lb.main
}

output "target_group_arn" {
  value = aws_lb_target_group.main
}

output "alb_listener_depends_on" {
  value      = {}
  depends_on = [aws_lb_listener.http, aws_lb_listener.https]
}
