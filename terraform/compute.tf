resource "aws_instance" "controlplane" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.controlplane_instance_type

  key_name = aws_key_pair.base_kp.key_name

  vpc_security_group_ids = [aws_security_group.controlplane_sg.id]

  root_block_device {
    delete_on_termination = true
    volume_size = 20
  }

  tags = {
    Name = "control-plane"
  }
}

resource "aws_instance" "worker" {
  count         = var.total_worker_instances
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.worker_instance_type

  key_name = aws_key_pair.base_kp.key_name

  vpc_security_group_ids = [aws_security_group.worker_sg.id]

  root_block_device {
    delete_on_termination = true
    volume_size = 30
  }

  tags = {
    Name = "worker-${count.index + 1}"
  }
}
