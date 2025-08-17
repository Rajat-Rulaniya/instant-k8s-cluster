#!/bin/bash

mkdir -p ~/.kube/ ## to create config will will it be idempotent?
touch ~/.kube/config

read controlplane_public_ip controlplane_private_ip < <(
    aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=control-plane" "Name=instance-state-name,Values=running" \
        --query 'Reservations[0].Instances[0].[PublicIpAddress,PrivateIpAddress]' \
        --output text
)

temp_kubeconfig=$(mktemp)
scp -i ~/.ssh/ec2 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@$controlplane_public_ip:~/.kube/config "$temp_kubeconfig"
sed -i "s/${controlplane_private_ip}/${controlplane_public_ip}/" "$temp_kubeconfig"
mv "$temp_kubeconfig" ~/.kube/config
