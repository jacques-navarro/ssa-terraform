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

resource "aws_security_group" "vpce-88-sg-pub" {
  vpc_id = local.vpc-id

  tags = {
    Name = "${local.name}sg${local.name-suffix-pub}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "vpce-88-igr-ssh" {
  security_group_id = aws_security_group.vpce-88-sg-pub.id
  cidr_ipv4         = local.cidr-all
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22

  tags = {
    Name = "${local.name}igr-ssh${local.name-suffix-pub}"
  }
}

resource "aws_vpc_security_group_egress_rule" "vpce-88-egr-all" {
  security_group_id = aws_security_group.vpce-88-sg-pub.id
  cidr_ipv4         = local.cidr-all
  from_port         = 1
  ip_protocol       = "tcp"
  to_port           = 65535

  tags = {
    Name = "${local.name}egr-all${local.name-suffix-pub}"
  }
}

resource "aws_instance" "vpce-88-ec2" {
  ami                         = "ami-06801a226628c00ce"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.vpce-88-subnet-pub.id
  associate_public_ip_address = true
  key_name                    = "ssh_aws_ed25519"
  security_groups             = [aws_security_group.vpce-88-sg-pub.id]


  tags = {
    Name = "${local.name}ec2${local.name-suffix-pub}"
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

resource "aws_vpc_endpoint" "vpce-88-endpoint-s3" {
  vpc_id          = local.vpc-id
  service_name    = "com.amazonaws.eu-central-1.s3"
  route_table_ids = [aws_route_table.vpce-88-rt-pri.id]
  auto_accept     = true

  tags = {
    Name = "${local.name}endpoint${local.name-suffix-pri}"
  }
}
