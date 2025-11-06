locals {
  wp_user_data = templatefile("${path.module}/cloud-init.yml", {
    DB_HOST     = var.db_host
    DB_NAME     = var.db_name
    DB_USER     = var.db_username
    DB_PASSWORD = var.db_password
  })
}

//security group for the private ec2 instances
resource "aws_security_group" "private_ec2_sg" {
  name        = "private_ec2_sg"
  description = "Security group for private ec2 instances"
  vpc_id      = var.vpc_id

  tags = {
    Name = "private_ec2_sg"
  }
}

//the inbound traffic for the security group for the private ec2 instances only allowing traffic from instances with the bastion host sg
resource "aws_vpc_security_group_ingress_rule" "private_ec2_ssh_traffic" {
  security_group_id            = aws_security_group.private_ec2_sg.id
  referenced_security_group_id = var.bastion_host_sg_id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

#allow HTTP traffic from the ALB
resource "aws_vpc_security_group_ingress_rule" "private_ec2_http" {
  security_group_id            = aws_security_group.private_ec2_sg.id
  referenced_security_group_id = var.alb_sg_id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

//the outbound traffic for the security group for the private ec2 instances
resource "aws_vpc_security_group_egress_rule" "private_ec2_outbound_traffic" {
  security_group_id = aws_security_group.private_ec2_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

//creates a private ec2 instance and attaches the sg created above
resource "aws_instance" "private1_ec2" {
  ami                    = "ami-075599e9cc6e3190d"
  instance_type          = "t3.micro"
  subnet_id              = var.private_subnet1_id
  vpc_security_group_ids = [aws_security_group.private_ec2_sg.id]
  user_data = local.wp_user_data
  user_data_replace_on_change = true
  key_name = "assignment"
  tags                   = { Name = "private1" }

}

//creates another private ec2 instance and attaches the same sg created above
resource "aws_instance" "private2_ec2" {
  ami                    = "ami-075599e9cc6e3190d"
  instance_type          = "t3.micro"
  subnet_id              = var.private_subnet2_id
  vpc_security_group_ids = [aws_security_group.private_ec2_sg.id]
  user_data = local.wp_user_data
  user_data_replace_on_change = true
  key_name = "assignment"
  tags                   = { Name = "private2" }

}

//makes the first private ec2 instance a target for the alb to send http traffic
resource "aws_lb_target_group_attachment" "web1" {
  target_group_arn = var.alb_target_group_arn
  target_id        = aws_instance.private1_ec2.id
  port             = 80
}

//makes the second private ec2 instance a target for the alb to send http traffic
resource "aws_lb_target_group_attachment" "web2" {
  target_group_arn = var.alb_target_group_arn
  target_id        = aws_instance.private2_ec2.id
  port             = 80
}