#
#

terraform {
  required_version = ">= 0.13"
}


provider "aws" {
  version    = "~> 3.0"
  region     = var.region
  access_key = ""
  secret_key = ""
}

resource "aws_vpc" "clip_vpc" {
  cidr_block = var.cidr_range

  tags = {
    Name = "VPC-clip_vpc"
  }

}


### Internet Gateway ###

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.clip_vpc.id

  tags = {
    Name = "Intenet Gateway for clip_vpc VPC"
  }
}



### Public Subnets

resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.clip_vpc.id
  cidr_block        = var.public_cidr_ranges[0]
  availability_zone = "us-east-1a"

  tags = {
    Name = "clip_vpc - Subnet public 1"
  }


}

resource "aws_subnet" "public2" {

  vpc_id            = aws_vpc.clip_vpc.id
  cidr_block        = var.public_cidr_ranges[1]
  availability_zone = "us-east-1b"

  tags = {
    Name = "clip_vpc - Subnet public 2"
  }


}

### Private Subnets

resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.clip_vpc.id
  cidr_block        = var.private_cidr_ranges[0]
  availability_zone = "us-east-1a"

  tags = {
    Name = "clip_vpc - Subnet private 1"
  }


}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.clip_vpc.id
  cidr_block        = var.private_cidr_ranges[1]
  availability_zone = "us-east-1b"

  tags = {
    Name = "clip_vpc - Subnet private 2"
  }

}

### Nat Gateway public1

resource "aws_eip" "nat_gateway_eip_p1" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway_p1" {
  allocation_id = aws_eip.nat_gateway_eip_p1.id
  subnet_id     = aws_subnet.public1.id
}

### Nat Gateway public2
resource "aws_eip" "nat_gateway_eip_p2" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway_p2" {
  allocation_id = aws_eip.nat_gateway_eip_p2.id
  subnet_id     = aws_subnet.public2.id
}

# Route tables
resource "aws_route_table" "rt_public1" {

  vpc_id = aws_vpc.clip_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

}

resource "aws_route_table_association" "rt_public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.rt_public1.id
}

resource "aws_route_table" "rt_public2" {

  vpc_id = aws_vpc.clip_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

}

resource "aws_route_table_association" "rt_public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.rt_public2.id
}

resource "aws_route_table" "rt_private1" {

  vpc_id = aws_vpc.clip_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_p1.id
  }

}

resource "aws_route_table_association" "rt_private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.rt_private1.id
}

resource "aws_route_table" "rt_private2" {

  vpc_id = aws_vpc.clip_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_p2.id
  }

}

resource "aws_route_table_association" "rt_private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.rt_private2.id
}
