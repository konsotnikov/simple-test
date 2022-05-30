resource "aws_security_group" "alb" {
  name   = "${var.projectname}-sg-alb-${var.env}"
  vpc_id = aws_vpc.main.id

  ingress {
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name         = "${var.projectname}-sg-alb-${var.env}"
    Project      = var.projectname
    Environment  = var.env
  }
}

resource "aws_security_group" "ecs_tasks" {
  name   = "${var.projectname}-sg-task-${var.env}"
  vpc_id = aws_vpc.main.id

  ingress {
    protocol         = "tcp"
    from_port        = var.container_port
    to_port          = var.container_port
    security_groups  = [aws_security_group.alb.id]
  }

  ingress {
    protocol         = "tcp"
    from_port        = 22
    to_port          = 22
    security_groups  = [aws_security_group.bastion.id]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name         = "${var.projectname}-sg-task-${var.env}"
    Project      = var.projectname
    Environment  = var.env
  }
}

resource "aws_security_group" "rds" {
  name   = "${var.projectname}-sg-rds-${var.env}"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol        = "tcp"
    from_port       = 3306
    to_port         = 3306
    security_groups = [aws_security_group.ecs_tasks.id, aws_security_group.bastion.id]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name         = "${var.projectname}-sg-rds-${var.env}"
    Project      = var.projectname
    Environment  = var.env
  }
}

resource "aws_security_group" "bastion" {
  name   = "${var.projectname}-sg-bastion-${var.env}"
  vpc_id = aws_vpc.main.id

  ingress {
    protocol         = "tcp"
    from_port        = 22
    to_port          = 22
    cidr_blocks      = var.bastion-acess-ips
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name         = "${var.projectname}-sg-bastion-${var.env}"
    Project      = var.projectname
    Environment  = var.env
  }
}