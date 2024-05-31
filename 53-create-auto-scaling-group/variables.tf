variable "ami-id" {
  default = "ami-0bd50a18ee156cba0"
}

variable "ssh-key" {
  default = "ssh_aws_ed25519"
}

variable "security-group-id" {
  default = "sg-082f2af5714b40905"
}

variable "availability-zones" {
  # type = list
  default = ["eu-central-1a", "eu-central-1b"]
}
