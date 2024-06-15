variable "ami-id" {
  # Ubuntu 24.04
  default = "ami-01e444924a2233b07"
}

variable "instance-type" {
  default = "t2.micro"
}

variable "ssh_key" {
  default = "ssh_aws_ed25519"
}
