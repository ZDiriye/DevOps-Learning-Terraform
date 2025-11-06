//security group for the bastion hosts
resource "aws_security_group" "bastion_ec2_sg" {
  name        = "bastion_ec2_sg"
  description = "Security group for the bastion hosts"
  vpc_id      = var.vpc_id

  tags = {
    Name = "bastion_ec2_sg"
  }
}

//the inbound traffic for the security group for the bastion hosts
resource "aws_vpc_security_group_ingress_rule" "bastion_ssh_traffic" {
  security_group_id = aws_security_group.bastion_ec2_sg.id
  cidr_ipv4         = "0.0.0.0/0" //should be restricted to my ip address but will leave it for now
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

//the outbound traffic for the security group for the bastion hosts
resource "aws_vpc_security_group_egress_rule" "bastion_outbound_traffic" {
  security_group_id = aws_security_group.bastion_ec2_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

//create a bastion host and associate the it's security group created above
resource "aws_instance" "bastion1_ec2" {
  ami                         = "ami-075599e9cc6e3190d"
  instance_type               = "t3.micro"
  subnet_id                   = var.public_subnet1_id
  vpc_security_group_ids      = [aws_security_group.bastion_ec2_sg.id]
  associate_public_ip_address = true
  key_name = "assignment"

  tags = { Name = "bastion1" }
}

//create the other bastion host and associate it to the same security group created above
resource "aws_instance" "bastion2_ec2" {
  ami                         = "ami-075599e9cc6e3190d"
  instance_type               = "t3.micro"
  subnet_id                   = var.public_subnet2_id
  vpc_security_group_ids      = [aws_security_group.bastion_ec2_sg.id]
  associate_public_ip_address = true
  key_name = "assignment"

  tags = { Name = "bastion2" }
}