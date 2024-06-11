variable "ami-id-c1" {
  default = "ami-06801a226628c00ce"
}

variable "ssh-key" {
  default = "ssh_aws_ed25519"
}

variable "instance-type-c1" {
  default = "t2.micro"
}

variable "ami-id-c2" {
  default = "ami-053ea2f9d1d6ac54c"
}

variable "instance-type-c2" {
  # t2.micro is not available in eu-central-2
  default = "t3.micro"
}
