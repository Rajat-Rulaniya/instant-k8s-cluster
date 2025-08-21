resource "local_file" "ansible_inventory" {
  content = <<-EOT
[control]
controlplane ansible_host=${aws_instance.controlplane.public_ip}

[workers]
%{ for index, worker in aws_instance.worker ~}
worker-${index + 1} ansible_host=${worker.public_ip}
%{ endfor ~}

[all:vars]
ansible_connection=ssh
ansible_user=ubuntu
ansible_ssh_private_key_file=${var.private_key_path}
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'

EOT

  filename = "${path.module}/../ansible/inventory.ini"
}