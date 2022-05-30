resource "aws_db_instance" "mysql" {
    identifier                = "${var.projectname}-rds-${var.env}"
    allocated_storage         = 10
    backup_retention_period   = 0
    multi_az                  = true
    engine                    = "mysql"
    engine_version            = "5.7"
    instance_class            = "db.t3.micro"
    username                  = "root"
    password                  = "${var.db_password}"
    port                      = "3306"
    db_subnet_group_name      = aws_db_subnet_group.mysql.id
    vpc_security_group_ids    = [aws_security_group.rds.id]
    skip_final_snapshot       = true
    publicly_accessible       = false

    tags = {
    Name         = "${var.projectname}-rds-${var.env}"
    Project      = var.projectname
    Environment  = var.env
  }
}

resource "aws_db_subnet_group" "mysql" {
  name          = "${var.projectname}-rds-sg-${var.env}"
  subnet_ids    = aws_subnet.private.*.id
  
  tags = {
    Name         = "${var.projectname}-rds-sg-${var.env}"
    Project      = var.projectname
    Environment  = var.env
  }
}


