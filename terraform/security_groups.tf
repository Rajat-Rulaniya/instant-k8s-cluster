resource "aws_security_group" "controlplane_sg" {
  name        = "controlplane_sg"
  description = "the security group which will be attached to control-plane"
}

resource "aws_security_group" "worker_sg" {
  name        = "worker_sg"
  description = "the security group which will be attached to worker nodes"
}

resource "aws_vpc_security_group_egress_rule" "egress_controlplane" {
  security_group_id = aws_security_group.controlplane_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
}

resource "aws_vpc_security_group_egress_rule" "egress_worker" {
  security_group_id = aws_security_group.worker_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
}

resource "aws_vpc_security_group_ingress_rule" "ingress_ssh_controlplane" {
  security_group_id = aws_security_group.controlplane_sg.id
  cidr_ipv4         = var.ssh_from_ip
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ingress_ssh_worker" {
  security_group_id = aws_security_group.worker_sg.id
  cidr_ipv4         = local.my_ip_cidr
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ingress_allow_all_traffic_to_controlplane" {
  security_group_id            = aws_security_group.controlplane_sg.id
  referenced_security_group_id = aws_security_group.worker_sg.id
  ip_protocol                  = -1
}

resource "aws_vpc_security_group_ingress_rule" "ingress_allow_all_traffic_to_worker" {
  security_group_id            = aws_security_group.worker_sg.id
  referenced_security_group_id = aws_security_group.controlplane_sg.id
  ip_protocol                  = -1
}

resource "aws_vpc_security_group_ingress_rule" "ingress_allow_apiserver_communication" {
  security_group_id = aws_security_group.controlplane_sg.id
  cidr_ipv4         = local.my_ip_cidr
  from_port         = 6443
  to_port           = 6443
  ip_protocol       = "tcp"
}