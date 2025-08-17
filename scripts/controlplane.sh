#!/bin/bash

sudo kubeadm init \
  --apiserver-advertise-address=$(hostname -I | awk '{print $1}') \
  --apiserver-cert-extra-sans=$(curl -s checkip.amazonaws.com),$(hostname -I | awk '{print $1}') \
  --pod-network-cidr="10.244.0.0/16" \
  --upload-certs \
  --ignore-preflight-errors=NumCPU,Mem

mkdir -p ~/.kube/
sudo cp /etc/kubernetes/admin.conf ~/.kube/config

sudo chown -R ubuntu:ubuntu ~/.kube

cat <<'EOF' > k
kubectl "$@"
EOF

sudo chmod +x k

sudo mv k /usr/bin/k

kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

echo sudo $(kubeadm token create --print-join-command) > /home/ubuntu/joinNodes.sh

cat <<'EOF' > update_cert.service
[Unit]
Description=Run script on reboot only
After=network.target

[Service]
Type=oneshot
User=ubuntu
ExecStart=/home/ubuntu/on_restart.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

sudo mv update_cert.service /etc/systemd/system/update_cert.service
sudo systemctl daemon-reload
sudo systemctl enable update_cert.service