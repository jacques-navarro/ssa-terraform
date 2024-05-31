provider "aws" {
  region = "eu-central-1"
}

resource "aws_launch_template" "asg-53-lt" {
  name                   = "asg-53-lt"
  image_id               = "ami-0bd50a18ee156cba0"
  instance_type          = "t2.micro"
  key_name               = "ssh_aws_ed25519"
  vpc_security_group_ids = ["sg-082f2af5714b40905"]

}

resource "aws_autoscaling_group" "asg-53-asg" {
  name               = "asg-53-asg"
  desired_capacity   = 2
  min_size           = 2
  max_size           = 2
  availability_zones = ["eu-central-1a", "eu-central-1b"]
  default_cooldown   = 60
  launch_template {
    id = aws_launch_template.asg-53-lt.id
  }
}
