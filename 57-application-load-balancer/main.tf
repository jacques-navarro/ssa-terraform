provider "aws" {
  region = "eu-central-1"
}

locals {
  name-prefix = "alb-57"
  name        = "57-alb"
}

resource "aws_vpc" "alb-57-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    name = "${local.name}-vpc"
  }
}

resource "aws_subnet" "alb-57-subnet-pub1" {
  vpc_id            = aws_vpc.alb-57-vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    name = "$(local.name)-subnet-pub1"
  }

}

resource "aws_subnet" "alb-57-subnet-pub2" {
  vpc_id            = aws_vpc.alb-57-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-central-1b"

  tags = {
    name = "$(local.name)-subnet-pub2"
  }
}

resource "aws_internet_gateway" "alb-57-ig" {
  vpc_id = aws_vpc.alb-57-vpc.id

  tags = {
    name = "$(local.name)-ig"
  }
}

resource "aws_route_table" "alb-57-rt" {
  vpc_id = aws_vpc.alb-57-vpc.id

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.alb-57-ig.id
  }
}

resource "aws_route_table_association" "alb-57-rta-pub1" {
  route_table_id = aws_route_table.alb-57-rt.id
  subnet_id      = aws_subnet.alb-57-subnet-pub1.id
}

resource "aws_route_table_association" "alb-57-rta-pub2" {
  route_table_id = aws_route_table.alb-57-rt.id
  subnet_id      = aws_subnet.alb-57-subnet-pub2.id
}

resource "aws_security_group" "alb-57-sg" {
  vpc_id = aws_vpc.alb-57-vpc.id

  tags = {
    name = "$(local.name)-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb-57-igr-ssh" {
  security_group_id = aws_security_group.alb-57-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22

  tags = {
    name = "$(local.name)-igr-ssh"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb-57-igr-http" {
  security_group_id = aws_security_group.alb-57-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80

  tags = {
    name = "$(local.name)-igr-http"
  }
}

resource "aws_vpc_security_group_egress_rule" "alb-57-egr-all" {
  security_group_id = aws_security_group.alb-57-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 1
  ip_protocol       = "tcp"
  to_port           = 65535

  tags = {
    name = "$(local.name)-egr-all"
  }
}

