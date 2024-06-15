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
  cidr_block           = local.cidr-local
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
  subnet_id      = aws_subnet.frp-128-sub-pub1.id
}

resource "aws_security_group" "frp-128-sg" {
  vpc_id = local.vpc-id

  tags = {
    Name = "${local.name}rt"
  }
}

resource "aws_route_table_association" "frp-128-rta-pub2" {
  route_table_id = aws_route_table.frp-128-rt.id
  subnet_id      = aws_subnet.frp-128-sub-pub2.id
}

resource "aws_vpc_security_group_ingress_rule" "frp-128-igr-ssh" {
  security_group_id = aws_security_group.frp-128-sg.id
  cidr_ipv4         = local.cidr-all
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22

  tags = {
    Name = "${local.name}igr-ssh"
  }
}

resource "aws_vpc_security_group_ingress_rule" "frp-128-igr-http" {
  security_group_id = aws_security_group.frp-128-sg.id
  cidr_ipv4         = local.cidr-all
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80

  tags = {
    Name = "${local.name}igr-http"
  }
}

resource "aws_launch_template" "frp-128-lt" {
  name          = "128-frp-lt"
  image_id      = "ami-06912d73bfa9ce345"
  instance_type = "t2.micro"

  key_name = "ssh_aws_ed25519"

  network_interfaces {
    associate_public_ip_address = true

    # security group must assigned in network interface
    security_groups = [aws_security_group.frp-128-sg.id]
  }

  user_data = filebase64("user_data.sh")

  tags = {
    Name = "${local.name}lt"
  }
}

resource "aws_autoscaling_group" "frp-128-asg" {
  name                = "128-frp-asg"
  desired_capacity    = 2
  min_size            = 2
  max_size            = 2
  vpc_zone_identifier = [aws_subnet.frp-128-sub-pub1.id, aws_subnet.frp-128-sub-pub2.id]
  default_cooldown    = 60
  target_group_arns = [aws_lb_target_group.frp-128-tg.id]

  launch_template {
    id = aws_launch_template.frp-128-lt.id
  }
}

resource "aws_lb_target_group" "frp-128-tg" {
  name     = "128-frp-tg"
  vpc_id   = local.vpc-id
  port     = 80
  protocol = "HTTP"

  tags = {
    Name = "${local.name}lt"
  }
}

resource "aws_lb" "frp-128-lb" {
  name            = "128-frp-lb"
  subnets         = [aws_subnet.frp-128-sub-pub1.id, aws_subnet.frp-128-sub-pub2.id]
  security_groups = [aws_security_group.frp-128-sg.id]

  tags = {
    Name = "${local.name}lb"
  }
}

resource "aws_lb_listener" "frp-128-lst" {
  load_balancer_arn = aws_lb.frp-128-lb.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.frp-128-tg.id
    type             = "forward"
  }
}
