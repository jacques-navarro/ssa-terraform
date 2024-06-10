provider "aws" {
  region = "eu-central-1"
}

locals {
  name              = "88-vpce-"
  name-suffix-pub   = "-pub"
  name-suffix-pri   = "-pri"
  vpc-id            = aws_vpc.vpce-88-vpc.id
  availability-zone = "eu-central-1a"
  cidr-local        = "10.0.0.0/16"
  cidr-all          = "0.0.0.0/0"
}

resource "aws_vpc" "vpce-88-vpc" {
  cidr_block           = local.cidr-local
  enable_dns_hostnames = true

  tags = {
    Name = "${local.name}vpc"
  }
}

resource "aws_subnet" "vpce-88-subnet-pub" {
  vpc_id            = local.vpc-id
  cidr_block        = "10.0.0.0/24"
  availability_zone = local.availability-zone

  tags = {
    Name = "${local.name}subnet${local.name-suffix-pub}"
  }
}

resource "aws_subnet" "vpce-88-subnet-pri" {
  vpc_id            = local.vpc-id
  cidr_block        = "10.0.1.0/24"
  availability_zone = local.availability-zone

  tags = {
    Name = "${local.name}subnet${local.name-suffix-pub}"
  }
}

resource "aws_internet_gateway" "vpce-88-ig" {
  vpc_id = local.vpc-id

  tags = {
    Name = "${local.name}ig"
  }
}

resource "aws_route_table" "vpce-88-rt-pub" {
  vpc_id = local.vpc-id

  route {
    cidr_block = local.cidr-local
    gateway_id = "local"
  }

  route {
    cidr_block = local.cidr-all
    gateway_id = aws_internet_gateway.vpce-88-ig.id
  }

  tags = {
    Name = "${local.name}rt${local.name-suffix-pub}"
  }

}

resource "aws_route_table_association" "vpce-88-rta-pub" {
  route_table_id = aws_route_table.vpce-88-rt-pub.id
  subnet_id      = aws_subnet.vpce-88-subnet-pub.id

}

resource "aws_route_table" "vpce-88-rt-pri" {
  vpc_id = local.vpc-id

  route {
    cidr_block = local.cidr-local
    gateway_id = "local"
  }

  tags = {
    Name = "${local.name}rt${local.name-suffix-pri}"
  }
}

resource "aws_route_table_association" "vpce-88-rta-pri" {
  route_table_id = aws_route_table.vpce-88-rt-pri.id
  subnet_id      = aws_subnet.vpce-88-subnet-pri.id
}
