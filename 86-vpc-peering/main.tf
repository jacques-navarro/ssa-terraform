provider "aws" {
  region = "eu-central-1"
}

locals {
  name = "86-vpcp-"
  vpc-id = aws_vpc.vpcp-86-vpc-c1.id
}

resource "aws_vpc" "vpcp-86-vpc-c1" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "${local.name}vpc-c1"
  }
}

resource "aws_subnet" "vpcp-86-subnet-c1" {
  vpc_id            = "${local.vpc-id}"
  cidr_block        = "10.0.0.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    Name = "${local.name}subnet-c1"
  }
}

resource "aws_internet_gateway" "vpcp-86-ig-c1" {
  vpc_id = "${local.vpc-id}"

  tags = {
    Name = "${local.name}ig-c1"
  }
}

resource "aws_route_table" "vpcp-86-rt-c1" {
  vpc_id = "${local.vpc-id}"

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpcp-86-ig-c1.id
  }

  tags = {
    Name = "${local.name}rt-c1"
  }
}

resource "aws_route_table_association" "vpcp-86-rta-c1" {
  route_table_id = aws_route_table.vpcp-86-rt-c1.id
  subnet_id = aws_subnet.vpcp-86-subnet-c1.id
}
