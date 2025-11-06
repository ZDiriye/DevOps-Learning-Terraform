//creates a private subnet in the eu-west-2a availability zone
resource "aws_subnet" "private1" {
  vpc_id                  = var.vpc_id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "private1_subnet"
  }
}

//creates a private subnet in the eu-west-2b availability zone
resource "aws_subnet" "private2" {
  vpc_id                  = var.vpc_id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "eu-west-2b"
  map_public_ip_on_launch = false

  tags = {
    Name = "private2_subnet"
  }
}

//creates the route table for one of the private subnet
resource "aws_route_table" "private_rt1" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.nat_gateway1
  }

  tags = {
    Name = "private_rt1"
  }
}

//creates the route table for the other private subnet
resource "aws_route_table" "private_rt2" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.nat_gateway2
  }

  tags = {
    Name = "private_rt2"
  }
}

//associates each route table to each of the private subnets
resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private_rt1.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private_rt2.id
}
