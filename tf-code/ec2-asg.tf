resource "aws_autoscaling_group" "main" {
  name                 = "${var.projectname}-asg-${var.env}"
  max_size             = 2
  min_size             = 2
  health_check_type    = "EC2"
  launch_configuration = aws_launch_configuration.main.name
  target_group_arns    = [aws_alb_target_group.main.arn]
  termination_policies = ["OldestInstance"]
  vpc_zone_identifier = aws_subnet.private.*.id
}

resource "aws_launch_configuration" "main" {
  iam_instance_profile        = aws_iam_instance_profile.main.name
  image_id                    = data.aws_ami.main.id
  instance_type               = "t3.micro"
  security_groups             = [aws_security_group.ecs_tasks.id]
  ## ECS_CLUSTER has to be the same as ECS cluster name
  user_data                   = "#!/bin/bash\necho ECS_CLUSTER=${var.projectname}-ecs-cluster-${var.env} >> /etc/ecs/ecs.config\nyum install telnet -y"
  key_name                    = "aws_pub_key"

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }
}

### ECS Instance Profile Resources - start

data "aws_iam_policy_document" "ecs_master" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "ecs_master" {
  name               = "${var.projectname}-ecs-master-role-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.ecs_master.json
  
}

resource "aws_iam_role_policy_attachment" "ecs_master" {
  role       = aws_iam_role.ecs_master.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "main" {
  name = "${var.projectname}-ecs-instance-profile-${var.env}"
  role = aws_iam_role.ecs_master.name
}

### ECS Instance Profile Resources - end


