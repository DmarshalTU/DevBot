variable "aws_region" {
  default = "us-east-1"
}

variable "ami" {
  default = "ami-09e67e426f25ce0d7"
}

variable "ssh-public-instance" {
  type = map(string)
  default = {
    "PATH_TO_PRIVATE_KEY" = "ssh/public-instance"
    "PATH_TO_PUBLIC_KEY" = "ssh/public-instance.pub"
  }
}

variable "ssh-private-instance" {
  type = map(string)
  default = {
    "PATH_TO_PRIVATE_KEY" = "ssh/private-instance"
    "PATH_TO_PUBLIC_KEY" = "ssh/private-instance.pub"
  }
}

variable "users" {
  type = map(string)
  default = {
    "ubuntu" = "ubuntu"
  }
}