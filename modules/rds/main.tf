//tells which private subnets the DB can use”
resource "aws_db_subnet_group" "wp" {
  name       = "wp-db-subnets"
  subnet_ids = [var.private_subnet1_id, var.private_subnet2_id]
  tags       = { Name = "wp-db-subnets" }
}

//creates sg for the db
resource "aws_security_group" "rds_sg" {
  name        = "rds-mysql-sg"
  description = "sg for the mysql database"
  vpc_id      = var.vpc_id
}

//creates the inbound rule only allowing traffic from the private ec2 instances to the mysql db through port 3306
resource "aws_vpc_security_group_ingress_rule" "rds_mysql_in" {
  security_group_id            = aws_security_group.rds_sg.id
  referenced_security_group_id = var.private_sg_id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "rds_all_out" {
  security_group_id = aws_security_group.rds_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

//creating mysql database
resource "aws_db_instance" "wp" {
  identifier        = "wp-mysql"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.wp.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  tags                   = { Name = "wp-mysql" }

  multi_az            = false
  publicly_accessible = false
  skip_final_snapshot = true
}