//creates the elastic ip for the nat gateway
resource "aws_eip" "nat_eip1" {
  domain = "vpc"
  tags = {
  Name = "nat-eip1" }
}

//creates the nategateway in a public subnet
resource "aws_nat_gateway" "nat_gateway1" {
  allocation_id = aws_eip.nat_eip1.id
  subnet_id     = var.public_subnet1_id

  tags = {
    Name = "nat_gw1"
  }
}

//creates the elastic ip for the nat gateway
resource "aws_eip" "nat_eip2" {
  domain = "vpc"
  tags = {
  Name = "nat-eip2" }
}

//creates the nategateway in the other public subnet
resource "aws_nat_gateway" "nat_gateway2" {
  allocation_id = aws_eip.nat_eip2.id
  subnet_id     = var.public_subnet2_id

  tags = {
    Name = "nat_gw2"
  }
}