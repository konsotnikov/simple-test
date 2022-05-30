### Dynamic Variables

variable "projectname" {
  default     = "simple"
}

variable "env" {
  default     = "test"
}

variable "aws-region" {
  type        = string
  default     = "us-east-2"
}

variable "cidr" {
  description = "The CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "List of CIDRs for private subnets in VPC"
  default     = ["10.0.0.0/20", "10.0.32.0/20", "10.0.64.0/20"]
}

variable "public_subnets" {
  description = "List of CIDRs for public subnets in VPC"
  default     = ["10.0.16.0/20", "10.0.48.0/20", "10.0.80.0/20"]
}

variable "availability_zones" {
  description = "a comma-separated list of availability zones, defaults to all AZ of the region, if set to something other than the defaults, both private_subnets and public_subnets have to be defined as well"
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

## Change on your own, please 
## Also needs to change in app.py
## ToDo: Use SSM instead of plain text
variable "db_password" {
  default     = "Some_Password_12345"
}

## ToDo - remove hardcode
variable "container_image" {
  default     = "<aws_ecr_repository.main.repository_url>/simple-test"
}

## ToDo: needs to change
variable "bastion-acess-ips" {
  description = "List of IPs for Bastion access. Should not use 0.0.0.0/0"
  default     = ["0.0.0.0/0"]
}

### Static Variables

data "aws_ami" "main" {
  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-2.0.202*-x86_64-ebs"]
  }
  most_recent = true
  owners      = ["amazon"]
}

variable "container_port" {
  description = "The port where the Docker is exposed"
  default     = 80
}

variable "health_check_path" {
  description = "Http path for task health check"
  default     = "/"
}

## ToDo: Use SSM instead of plain text

variable "pub_key_ssh" {
  description = "Path to public key to ssh into instance."
  default     = "./keys/id_rsa_simple_test.pub"
}

resource "aws_key_pair" "main" {
  key_name   = "aws_pub_key"
  public_key = file(var.pub_key_ssh)

  tags = {
    Name         = "${var.projectname}-pub-key-${var.env}"
    Project      = var.projectname
    Environment  = var.env
  }
}

## One of options for Bastion subnet
#resource "random_shuffle" "bastion-sn" {
#  input        = [aws_subnet.public.*.id]
#  result_count = 1
#}
