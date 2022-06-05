# Simple Project for Flask/RDS/AWS ECS/EC2

This application/terraform setup can be used to setup the AWS infrastructure
for a dockerized application running on ECS with EC2 launch configuration.

!(diagram.png)"Infrastructure illustration")

## Resources

This setup creates the following resources:

- VPC
- Three public and three private subnets across different AZs
- Routing tables for the subnets
- Internet Gateway for public subnets
- NAT gateways with attached Elastic IPs for the private subnets
- Four security groups
  - external HTTP access
  - access to ECS tasks
  - database access
  - bastion host access
- An ALB + target group with listener for port 80
- An ECR for the docker images
- An ECS cluster with a service and task definition to run docker containers from the ECR
- An RDS in private subnet
- An EC2 as bastion host
- Key pair for SSH access (generated only for this project)

### Get Started building the project

#### Dependencies
- Install terraform version 1.2.1
- Install aws cli
- Install docker-ce
- AWS profile configuration `aws configure` and add your AWS_SECRET_ACCESS_KEY and AWS_SECRET_KEY 
  (It is on your own. There are many secure options how to share your secrets with terraform.)
- Generate a key pair `ssh-keygen -f /<path_to_tf-code_directory>/keys/id_rsa_simple_test` to EC2 access

#### Infrastructure
- Choose TF backend in provider.tf (local by default)
- Fill out "Dynamic Variables" in variables.tf (ToDo - remove all hardcode for subnets and DB password)
- Build infrastructure - `cd /<path_to_tf-code_directory>/` `terraform init` `terraform apply`

#### Docker Image
- Copy RDS DNS name from tf outputs and paste it to `app.py` (ToDo - remove hardcode)
- Build Docker image - `cd /<path_to_simple-app_directory>/` `docker build -t simple-test .`
- Get ECR tocken - `aws ecr get-login-password --region <aws_region> | docker login --username AWS --password-stdin <ecr_url_from_tf_outputs>`
- Tagging - `docker tag simple-test:latest <ecr_url_from_tf_outputs>:latest`
- Pushing - `docker push <ecr_url_from_tf_outputs>:latest`

#### Checking
##### Copy ALB DNS name from tf outputs and paste it in your browser:
  - "/" just show a message
  - "/dbcreate" - will create database "my_tests"
  - "/dbdrop" - will drop database "my_tests"
  - (ToDo - add "SHOW DATABASES;" output)
  - All endpoints return 200 - `curl -I <alb_dns_name>{/|/dbcreate|/dbdrop}`
##### Connect to the bastion host:
  - Take bastion public IP address from tf outputs and use `ssh -i /<path_to_tf-code_directory>/keys/id_rsa_simple_test ec2-user@<bastion_ip_address>`
##### Connect to the ECS cluster node:
  - From bastion host - `ssh -i ~/.ssh/id_rsa_simple_test ec2-user@<node_private_ip_address>
##### Connect to RDS:
  - From bastion host - `mysql -uroot -p<password_from_app.py> -h<rds_dns_name_from_app.py>` (ToDo - use different user, remove hardcode)
  - `SHOW DATABASES;`


<!-- ![example](https://<url> "Infrastructure illustration")
(Source: https://<url>)-->
