data "aws_region" "aws_account_region" {}
locals {
  RESOURCE_NAME = "${var.PROJECT_NAME}-${var.ENV}-${var.RESOURCE_SUFFIX}"
  AWS_REGION    = data.aws_region.aws_account_region.name
}


##################################################################
# Application Load Balancer
##################################################################

resource "aws_lb" "application-load-balancer" {
  name               = local.RESOURCE_NAME
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.SECURITY_GROUP_ID]
  subnets            = [for subnet in var.SUBNET_PUBLICS : subnet]
  enable_deletion_protection = true
  tags = merge(var.AWS_TAGS, {
    Name = local.RESOURCE_NAME
  })

}
resource "aws_lb_listener" "lb-listener-443-forwar" {
  load_balancer_arn = aws_lb.application-load-balancer.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.CERTIFICATE_ARN

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target-group-80.arn
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.application-load-balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}


resource "aws_lb_target_group" "target-group-80" {
  name     = "${var.PROJECT_NAME}-${var.ENV}-tg-80"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.VPC_ID
  tags = var.AWS_TAGS
  target_type = "ip"
  lifecycle {
    create_before_destroy = true
  }
  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 30
    timeout = 5
    healthy_threshold = 5
    unhealthy_threshold = 2
  }
}

resource "aws_route53_record" "domain_name" {
  zone_id = var.ROUTE_53_ZONE_ID
  name    = var.DOMAIN_NAME_BACKEND
  type    = "A"
  allow_overwrite = true
  alias {
    name                   = aws_lb.application-load-balancer.dns_name
    zone_id                = aws_lb.application-load-balancer.zone_id
    evaluate_target_health = true
  }
}