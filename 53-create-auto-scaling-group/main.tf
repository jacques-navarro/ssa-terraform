provider "aws" {
  region = "eu-central-1"
}

locals {
  name-prefix = "asg-53"
  name        = "53-asg"
}

resource "aws_vpc" "asg-53-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    name = "${local.name}-vpc"
  }
}

resource "aws_subnet" "asg-53-subnet-pub1" {
  vpc_id            = aws_vpc.asg-53-vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    name = "${local.name}-subnet-pub1"
  }
}

resource "aws_subnet" "asg-53-subnet-pub2" {
  vpc_id            = aws_vpc.asg-53-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-central-1b"

  tags = {
    name = "${local.name}-subnet-pub2"
  }
}

resource "aws_route_table" "asg-53-rt" {
  vpc_id = aws_vpc.asg-53-vpc.id

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.asg-53-ig.id
  }

  tags = {
    name = "${local.name}-rt"
  }
}

resource "aws_internet_gateway" "asg-53-ig" {
  vpc_id = aws_vpc.asg-53-vpc.id

  tags = {
    name = "${local.name}-ig"
  }
}

resource "aws_route_table_association" "asg-53-rta-pub1" {
  route_table_id = aws_route_table.asg-53-rt.id
  subnet_id      = aws_subnet.asg-53-subnet-pub1.id
}

resource "aws_route_table_association" "asg-53-rta-pub2" {
  route_table_id = aws_route_table.asg-53-rt.id
  subnet_id      = aws_subnet.asg-53-subnet-pub2.id
}

resource "aws_security_group" "asg-53-sg" {
  vpc_id = aws_vpc.asg-53-vpc.id
  name   = "asg-53-sg"

  tags = {
    name = "${local.name}-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "asg-53-igr-ssh" {
  security_group_id = aws_security_group.asg-53-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22

  tags = {
    name = "${local.name}-igr-ssh"
  }
}

resource "aws_vpc_security_group_egress_rule" "asg-53-egr-ssh" {
  security_group_id = aws_security_group.asg-53-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22

  tags = {
    name = "${local.name}-egr-ssh"
  }
}

resource "aws_launch_template" "asg-53-lt" {
  name                   = "${local.name-prefix}-lt"
  image_id               = var.ami-id
  instance_type          = "t2.micro"
  key_name               = var.ssh-key
  vpc_security_group_ids = [var.security-group-id]

  tags = {
    name= "53-asg-lt"
  }
}

resource "aws_autoscaling_group" "asg-53-asg" {
  name               = "${local.name-prefix}-asg"
  desired_capacity   = 2
  min_size           = 2
  max_size           = 2
  availability_zones = [var.availability-zones[0], var.availability-zones[1]]
  default_cooldown   = 60

  launch_template {
    id = aws_launch_template.asg-53-lt.id
  }

}
