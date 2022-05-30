resource "aws_alb" "main" {
  name               = "${var.projectname}-alb-${var.env}"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public.*.id

  enable_deletion_protection = false

  tags = {
    Name         = "${var.projectname}-alb-${var.env}"
    Project      = var.projectname
    Environment  = var.env
  }
}

resource "aws_alb_target_group" "main" {
  name        = "${var.projectname}-tg-${var.env}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    protocol            = "HTTP"
    matcher             = "200"
    path                = var.health_check_path
  }

  tags = {
    Name         = "${var.projectname}-tg-${var.env}"
    Project      = var.projectname
    Environment  = var.env
  }
}

resource "aws_alb_listener" "main" {
  load_balancer_arn = aws_alb.main.id
  port              = 80
  protocol          = "HTTP"

  default_action {
        target_group_arn = aws_alb_target_group.main.id
        type             = "forward"
  }
}


