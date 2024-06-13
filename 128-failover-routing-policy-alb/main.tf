provider "aws" {
  region = "eu-central-1"
}

locals {
  name       = "128-frp-"
  cidr-all   = "0.0.0.0/0"
  cidr-local = "10.0.0.0/16"
  vpc-id     = aws_vpc.frp-128-vpc-c1.id
}

resource "aws_vpc" "frp-128-vpc-c1" {
  cidr_block = local.cidr-local
  enable_dns_hostnames = true

  tags = {
    Name = "${local.name}vpc"
  }
}

resource "aws_subnet" "frp-128-sub-pub1" {
  vpc_id            = local.vpc-id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    Name = "${local.name}subnet-pub1"
  }
}

resource "aws_subnet" "frp-128-sub-pub2" {
  vpc_id            = local.vpc-id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-central-1b"

  tags = {
    Name = "${local.name}subnet-pub2"
  }
}

resource "aws_internet_gateway" "frp-128-ig" {
  vpc_id = local.vpc-id

  tags = {
    Name = "${local.name}ig"
  }
}

resource "aws_route_table" "frp-128-rt" {
  vpc_id = local.vpc-id

  route {
    cidr_block = local.cidr-local
    gateway_id = "local"
  }

  route {
    cidr_block = local.cidr-all
    gateway_id = aws_internet_gateway.frp-128-ig.id

  }

  tags = {
    Name = "${local.name}rt"
  }
}

resource "aws_route_table_association" "frp-128-rta-pub1" {
  route_table_id = aws_route_table.frp-128-rt.id
  subnet_id = aws_subnet.frp-128-sub-pub1.id
}

resource "aws_route_table_association" "frp-128-rta-pub2" {
  route_table_id = aws_route_table.frp-128-rt.id
  subnet_id = aws_subnet.frp-128-sub-pub2.id
}
