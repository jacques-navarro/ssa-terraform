provider "aws" {
  region = local.region
}

locals {
  region            = "eu-central-1"
  name              = "86-vpcp-"
  name-suffix       = "-c1"
  vpc-id            = aws_vpc.vpcp-86-vpc-c1.id
  sg-id             = aws_security_group.vpcp-86-sg-c1.id
  cidr-local        = "10.0.0.0/16"
  cidr-subnet       = "10.0.0.0/24"
  cidr-all          = "0.0.0.0/0"
  availability-zone = "eu-central-1a"
}

resource "aws_vpc" "vpcp-86-vpc-c1" {
  cidr_block           = local.cidr-local
  enable_dns_hostnames = true

  tags = {
    Name = "${local.name}vpc${local.name-suffix}"
  }
}

resource "aws_subnet" "vpcp-86-subnet-c1" {
  vpc_id            = local.vpc-id
  cidr_block        = local.cidr-subnet
  availability_zone = local.availability-zone

  tags = {
    Name = "${local.name}subnet${local.name-suffix}"
  }
}

resource "aws_internet_gateway" "vpcp-86-ig-c1" {
  vpc_id = local.vpc-id

  tags = {
    Name = "${local.name}ig${local.name-suffix}"
  }
}

resource "aws_route_table" "vpcp-86-rt-c1" {
  vpc_id = local.vpc-id

  route {
    cidr_block = local.cidr-local
    gateway_id = "local"
  }

  route {
    cidr_block = local.cidr-all
    gateway_id = aws_internet_gateway.vpcp-86-ig-c1.id
  }

  tags = {
    Name = "${local.name}rt${local.name-suffix}"
  }
}

resource "aws_route_table_association" "vpcp-86-rta-c1" {
  route_table_id = aws_route_table.vpcp-86-rt-c1.id
  subnet_id = aws_subnet.vpcp-86-subnet-c1.id
}
