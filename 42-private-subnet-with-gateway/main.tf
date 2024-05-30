provider "aws" {
  region = "eu-central-1"
}

resource "aws_vpc" "nat-gateway" {
  cidr_block         = "10.0.0.0/16"
  enable_dns_support = true

  tags = {
    Name = var.name
  }
}

resource "aws_internet_gateway" "nat-gateway" {
  vpc_id = aws_vpc.nat-gateway.id

  tags = {
    Name = var.name
  }
}

resource "aws_subnet" "nat-gateway-public" {
  vpc_id            = aws_vpc.nat-gateway.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    Name = var.name
  }
}


# private subnet, security group, ingress rule, nat-gateway, route table association, route table, instance

resource "aws_subnet" "nat-gateway-private" {
  vpc_id            = aws_vpc.nat-gateway.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    Name = var.name
  }
}

resource "aws_security_group" "nat-gateway" {
  name   = "nat-gateway-ssh"
  vpc_id = aws_vpc.nat-gateway.id

  tags = {
    Name = var.name
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh-rule" {
  security_group_id = aws_security_group.nat-gateway.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22

  tags = {
    Name = var.name
  }
}

resource "aws_vpc_security_group_egress_rule" "ssh-rule" {
  security_group_id = aws_security_group.nat-gateway.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 22
  ip_protocol = "tcp"
  to_port = 22
}

resource "aws_eip" "nat-gateway" {
  depends_on = [aws_internet_gateway.nat-gateway]

}

resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.nat-gateway.id
  subnet_id     = aws_subnet.nat-gateway-public.id
  depends_on    = [aws_internet_gateway.nat-gateway]
  private_ip    = "10.0.0.20"

  tags = {
    Name = var.name
  }
}

resource "aws_route_table_association" "nat-gateway-local" {
  subnet_id      = aws_subnet.nat-gateway-private.id
  route_table_id = aws_route_table.nat-gateway.id
}

resource "aws_route_table" "nat-gateway" {
  vpc_id = aws_vpc.nat-gateway.id

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-gateway.id
  }

  tags = {
    Name = var.name
  }
}

resource "aws_route_table_association" "internet-gateway" {
  subnet_id      = aws_subnet.nat-gateway-public.id
  route_table_id = aws_route_table.internet-gateway.id
}

resource "aws_route_table" "internet-gateway" {
  vpc_id = aws_vpc.nat-gateway.id

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nat-gateway.id
  }

  tags = {
    Name = var.name
  }
}

resource "aws_instance" "nat-gateway" {
  ami                    = var.ami-id
  instance_type          = "t2.micro"
  availability_zone      = "eu-central-1a"
  subnet_id              = aws_subnet.nat-gateway-private.id
  private_ip             = "10.0.1.10"
  key_name               = var.ssh-key
  vpc_security_group_ids = [aws_security_group.nat-gateway.id]


  tags = {
    Name = var.name
  }
}

resource "aws_instance" "nat-gateway-public" {
  ami                    = var.ami-id
  instance_type          = "t2.micro"
  availability_zone      = "eu-central-1a"
  subnet_id              = aws_subnet.nat-gateway-public.id
  associate_public_ip_address = true
  private_ip             = "10.0.0.10"
  key_name               = var.ssh-key
  vpc_security_group_ids = [aws_security_group.nat-gateway.id]
}
