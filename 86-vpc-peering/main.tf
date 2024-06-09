provider "aws" {
  alias = "c1"
  region = local.region-c1
}

locals {
  name              = "86-vpcp-"
  cidr-local        = "10.0.0.0/16"
  cidr-all          = "0.0.0.0/0"

  region-c1            = "eu-central-1"
  name-suffix-c1       = "-c1"
  vpc-id-c1            = aws_vpc.vpcp-86-vpc-c1.id
  sg-id-c1             = aws_security_group.vpcp-86-sg-c1.id
  cidr-subnet-c1       = "10.0.0.0/24"
  availability-zone-c1 = "eu-central-1a"
}

resource "aws_vpc" "vpcp-86-vpc-c1" {
  provider = aws.c1
  cidr_block           = local.cidr-local
  enable_dns_hostnames = true

  tags = {
    Name = "${local.name}vpc${local.name-suffix-c1}"
  }
}

resource "aws_subnet" "vpcp-86-subnet-c1" {
  provider = aws.c1
  vpc_id            = local.vpc-id-c1
  cidr_block        = local.cidr-subnet-c1
  availability_zone = local.availability-zone-c1

  tags = {
    Name = "${local.name}subnet${local.name-suffix-c1}"
  }
}

resource "aws_internet_gateway" "vpcp-86-ig-c1" {
  provider = aws.c1
  vpc_id = local.vpc-id-c1

  tags = {
    Name = "${local.name}ig${local.name-suffix-c1}"
  }
}

resource "aws_route_table" "vpcp-86-rt-c1" {
  provider = aws.c1
  vpc_id = local.vpc-id-c1

  route {
    cidr_block = local.cidr-local
    gateway_id = "local"
  }

  route {
    cidr_block = local.cidr-all
    gateway_id = aws_internet_gateway.vpcp-86-ig-c1.id
  }

  tags = {
    Name = "${local.name}rt${local.name-suffix-c1}"
  }
}

resource "aws_route_table_association" "vpcp-86-rta-c1" {
  provider = aws.c1
  route_table_id = aws_route_table.vpcp-86-rt-c1.id
  subnet_id      = aws_subnet.vpcp-86-subnet-c1.id
}

resource "aws_security_group" "vpcp-86-sg-c1" {
  provider = aws.c1
  vpc_id = local.vpc-id-c1

  tags = {
    Name = "${local.name}sg${local.name-suffix-c1}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "vpcp-86-igr-ssh-c1" {
  provider = aws.c1
  security_group_id = local.sg-id-c1

  cidr_ipv4   = local.cidr-all
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22

  tags = {
    Name = "${local.name}igr-ssh${local.name-suffix-c1}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "vpc-86-igr-icmp" {
  provider = aws.c1
  security_group_id = local.sg-id-c1
  cidr_ipv4         = local.cidr-local
  from_port         = 8
  ip_protocol       = "icmp"
  to_port           = 0
}

resource "aws_instance" "vpcp-86-ec2-c1" {
  provider = aws.c1
  ami                         = var.ami-id
  instance_type               = var.instance-type
  subnet_id                   = aws_subnet.vpcp-86-subnet-c1.id
  associate_public_ip_address = true
  key_name                    = var.ssh-key
  vpc_security_group_ids      = ["${local.sg-id-c1}"]

  tags = {
    Name = "${local.name}ec2${local.name-suffix-c1}"
  }
}
