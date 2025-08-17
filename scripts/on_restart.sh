#!/bin/bash

set -e

FLAG_FILE="/run/update_cert_ran"

if [ -f "$FLAG_FILE" ]; then
    exit 0
fi

sudo touch "$FLAG_FILE"

sudo mv /etc/kubernetes/pki/apiserver.crt /etc/kubernetes/pki/apiserver.crt.bak
sudo mv /etc/kubernetes/pki/apiserver.key /etc/kubernetes/pki/apiserver.key.bak

sudo kubeadm init phase certs apiserver \
  --apiserver-cert-extra-sans=$(curl -s checkip.amazonaws.com),$(hostname -I | awk '{print $1}')

sudo systemctl restart kubelet

sudo cp /etc/kubernetes/admin.conf ~/.kube/config
sudo chown -R ubuntu:ubuntu ~/.kube
