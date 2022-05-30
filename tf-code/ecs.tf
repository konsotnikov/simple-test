resource "aws_ecs_cluster" "main" {
  name = "${var.projectname}-ecs-cluster-${var.env}"

  lifecycle {
    create_before_destroy = true
  }

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name         = "${var.projectname}-ecs-cluster-${var.env}"
    Project      = var.projectname
    Environment  = var.env
  }
}

resource "aws_ecs_task_definition" "main" {
  family                   = "${var.projectname}-task-${var.env}"
  network_mode             = "host"
  memory                   = 500
  requires_compatibilities = ["EC2"]

  container_definitions    = jsonencode([{
    name        = "${var.projectname}-container-${var.env}"
    image       = "${var.container_image}:latest"
    essential   = true
    portMappings = [{
      protocol      = "tcp"
      containerPort = var.container_port
      hostPort      = var.container_port
    }]
  }])

#  logConfiguration = {
#      logDriver = "awslogs"
#      options = {
#        awslogs-group         = aws_cloudwatch_log_group.main.name
#        awslogs-stream-prefix = "ecs"
#        awslogs-region        = var.region
#      }
#    }
#  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
#  task_role_arn            = aws_iam_role.ecs_task_role.arn

  tags = {
    Name         = "${var.projectname}-task-${var.env}"
    Project      = var.projectname
    Environment  = var.env
  }
}

resource "aws_ecs_service" "main" {
  name                    = "${var.projectname}-service-${var.env}"
  cluster                 = aws_ecs_cluster.main.id
  task_definition         = aws_ecs_task_definition.main.arn
  desired_count           = 2
  enable_ecs_managed_tags = true
  force_new_deployment    = true

  load_balancer {
    target_group_arn = aws_alb_target_group.main.arn
    container_name   = "${var.projectname}-container-${var.env}"
    container_port   = 80
  }

  tags = {
    Name         = "${var.projectname}-service-${var.env}"
    Project      = var.projectname
    Environment  = var.env
  }
}

