variable "aws_lb" {}
variable "aws_route53_records" {}
variable "lb_target_group_arn" {}

resource "aws_lb_listener" "https" {

  for_each = var.aws_route53_records

  load_balancer_arn = var.aws_lb.arn
  port = "443"
  protocol = "HTTPS"
  certificate_arn = each.value.aws_acm_arm
  ssl_policy = "ELBSecurityPolicy-2016-08"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "THIS IS HTTPS!!!"
      status_code = "200"
    }
  }
}


resource "aws_alb_listener_rule" "main" {

  for_each = var.aws_route53_records
  listener_arn = aws_lb_listener.https[each.key].arn
  priority = 100

  action {
    type = "forward"
    target_group_arn = lb_target_group_arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}