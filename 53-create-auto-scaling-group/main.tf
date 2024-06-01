provider "aws" {
  region = "eu-central-1"
}

locals {
  name-prefix = "asg-53"
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
