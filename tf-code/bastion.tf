resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.main.id
  instance_type               = "t3.micro"
  disable_api_termination     = "false"
  key_name                    = "aws_pub_key"
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  
  ## ToDo - remove hardcode for subnet
  ## 2 options:
  ## - random_shuffle.bastion-sn.result(bastion could recreate every code run) 
  ## - additional ASG
  subnet_id                   = aws_subnet.public.1.id 
  
  user_data = <<-EOF
    #!/bin/bash -xe
    exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
    yum install telnet mysql -y
EOF

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 30
    encrypted             = "true"
    delete_on_termination = "false"
  }

  provisioner "file" {
    source      = "id_rsa_simple_test*"
    destination = "/home/ec2-user/.ssh/"

    connection {
      type     = "ssh"
      user     = "ec2-user"
      private_key = "${file("id_rsa_simple_test")}"
      host     = aws_instance.bastion.public_ip
    }
  }

  tags = {
    Name         = "${var.projectname}-bastion-${var.env}"
    Project      = var.projectname
    Environment  = var.env
  }
}

resource "aws_eip" "bastion_eip" {
  instance = aws_instance.bastion.id
  vpc      = true

  tags = {
    Name         = "${var.projectname}-bastion-eip-${var.env}"
    Project      = var.projectname
    Environment  = var.env
  }
}
