resource "aws_lb" "callsign" {
  name               = "callsign"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.callsign_lb.id]
  subnets            = module.vpc.public_subnets
}

resource "aws_security_group" "callsign_lb" {
  name   = "callsign-lb"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = var.app_port
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
}

resource "aws_lb_target_group" "callsign" {
  name        = "callsign"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    interval            = 30
    path                = "/health"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "callsign_http_listener" {
  load_balancer_arn = aws_lb.callsign.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.callsign.arn
  }
}

