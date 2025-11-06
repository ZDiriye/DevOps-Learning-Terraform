locals {
  public_subnet_ids = [var.public_subnet1_id, var.public_subnet2_id]
}

//security group for the alb
resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Security group for the application load balancer"
  vpc_id      = var.vpc_id

  tags = {
    Name = "alb_sg"
  }
}

//the inbound traffic for the security group for the alb
resource "aws_vpc_security_group_ingress_rule" "alb_http_traffic" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

//the outbound traffic for the security group for the alb
resource "aws_vpc_security_group_egress_rule" "alb_outbound_traffic" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

//creates the alb
resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = local.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

//creates of the target group for the alb
resource "aws_lb_target_group" "alb" {
  name     = "alb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health.html"
    matcher             = "200"
    interval            = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }
}

//creates of the listener for the alb which directs traffic to the target groups
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb.arn
  }
}
