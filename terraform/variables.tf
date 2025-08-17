variable "aws_region" {
  default = "us-east-1"
}

variable "ssh_from_ip" {
  default = "0.0.0.0/0"
}

locals {
  my_ip_cidr = "${chomp(data.http.my_ip.response_body)}/32"
}

variable "controlplane_instance_type" {
  default = "t3.medium"
}

variable "worker_instance_type" {
  default = "t3.medium"
}

variable "total_worker_instances" {
  default = 2
  type = number
}

variable "public_key_path" {
  default = "~/.ssh/ec2.pub"
}

variable "private_key_path" {
  default = "~/.ssh/ec2"
}