# ACME Certificate Resources
resource "acme_registration" "reg" {
  count         = var.create_alb ? 1 : 0
  email_address = var.acme_email
}

resource "acme_certificate" "cert" {
  count                     = var.create_alb ? 1 : 0
  account_key_pem           = acme_registration.reg[0].account_key_pem
  common_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names

  dns_challenge {
    provider = "route53"
    config = {
      AWS_DEFAULT_REGION         = var.aws_region
    }
  }
}

resource "aws_acm_certificate" "cert" {
  count             = var.create_alb ? 1 : 0
  private_key       = acme_certificate.cert[0].private_key_pem
  certificate_body  = acme_certificate.cert[0].certificate_pem
  certificate_chain = acme_certificate.cert[0].issuer_pem
}

# ALB Security Group
resource "aws_security_group" "alb_sg" {
  count       = var.create_alb ? 1 : 0
  name        = "alb-sg"
  description = "Allow inbound HTTP/HTTPS traffic"
  vpc_id      = aws_vpc.aap_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "ALB-SG"
    Terraform = "true"
  }
}

# ALB Target Group
resource "aws_lb_target_group" "app_tg" {
  count    = var.create_alb ? 1 : 0
  name     = "aap-target-group"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = aws_vpc.aap_vpc.id

  health_check {
    path                = "/"
    port                = "443"
    protocol            = "HTTPS"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

# Application Load Balancer
resource "aws_lb" "aap_alb" {
  count              = var.create_alb ? 1 : 0
  name               = "aap-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg[0].id]
  subnets = [
    aws_subnet.aap_public_subnet_az1.id,
    aws_subnet.aap_public_subnet_az2.id
  ]

  tags = {
    Name      = "AAP-ALB"
    Terraform = "true"
  }
}

# HTTPS Listener
resource "aws_lb_listener" "https" {
  count             = var.create_alb ? 1 : 0
  load_balancer_arn = aws_lb.aap_alb[0].arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert[0].arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg[0].arn
  }
}

# HTTP Redirect Listener
resource "aws_lb_listener" "http_redirect" {
  count             = var.create_alb ? 1 : 0
  load_balancer_arn = aws_lb.aap_alb[0].arn
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

# Target Group Attachment
resource "aws_lb_target_group_attachment" "attach_instance" {
  count            = var.create_alb ? 1 : 0
  target_group_arn = aws_lb_target_group.app_tg[0].arn
  target_id        = aws_instance.aap_instance.id
  port             = 443
}

# Security Group Rule for ALB to Instance
resource "aws_security_group_rule" "alb_to_instance" {
  count                    = var.create_alb ? 1 : 0
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_sg[0].id
  security_group_id        = aws_security_group.aap_security_group.id
}

# Route53 Data Source
data "aws_route53_zone" "hashidemos_zone" {
  count        = var.create_alb ? 1 : 0
  name         = var.route53_zone_name
  private_zone = false
}

# Route53 Record
resource "aws_route53_record" "aap_alb_dns" {
  count   = var.create_alb ? 1 : 0
  zone_id = data.aws_route53_zone.hashidemos_zone[0].id
  name    = var.domain_name
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.aap_alb[0].dns_name]
}

resource "terraform_data" "wait_for_healthy_target" {
  count   = var.create_alb ? 1 : 0
  
  provisioner "local-exec" {
    command = <<EOT
      echo "Waiting for target to become healthy..."
      for i in {1..50}; do
        status=$(aws --region ${var.aws_region} elbv2 describe-target-health \
          --target-group-arn ${aws_lb_target_group.app_tg[0].arn} \
          --query 'TargetHealthDescriptions[0].TargetHealth.State'  \
          --output text)

        echo "Current health status: $status"

        if [ "$status" = "healthy" ]; then
          echo "Target is healthy!"
          sleep 10
          exit 0
        fi

        sleep 10
      done

      echo "Timed out waiting for target to become healthy."
      exit 
    EOT
  }

  depends_on = [
    aws_instance.aap_instance,
    aws_lb_target_group.app_tg[0],
    aws_route53_record.aap_alb_dns[0]
  ]

  triggers_replace = {
    instance_id = aws_instance.aap_instance.id
    alb_arn     = aws_lb.aap_alb[0].arn
  }
} 