#!/bin/bash

set -e

cd terraform

if [ ! -d ".terraform" ]; then
    printf "[INFO] Running 'terraform init'....\n"
    terraform init
fi

if terraform state list 2> /dev/null | grep -q .; then
    printf "\e[1;33m[INFO]\e[0m Cluster already running, first delete using -> ./destroy_cluster.sh -y\n"
    exit 0
fi

# if [ -f terraform.tfstate ] && ! grep -q '"resources": \[\]' terraform.tfstate; then
#     printf "[INFO] Cluster already running, first delete using -> ./destroy_cluster.sh -y\n"
#     exit 0
# fi

printf "🚀 Starting Terraform Provisioning.......\n\n"

terraform apply -auto-approve

printf "\n\n✅✅ Terrafrom Provisioning Successfull !!\n\n"

sleep 15

printf "\n\n🚀 Starting Ansible automation.......\n\n"

cd ../ansible
ansible-playbook -i inventory.ini site.yml

printf "\n\n✅✅ Ansible automation Successfull !!\n\n"

printf "🚀 Updating local kubeconfig file.......\n\n"

cd ..
chmod +x update_kubeconfig.sh
./update_kubeconfig.sh

printf "\n\n✅✅ Local kubeconfig update Successfull, now run any kubectl command !!\n"