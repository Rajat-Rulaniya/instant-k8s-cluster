#!/bin/bash

set -e

printf "⚒️⚒️ Destroying cluster....... 🧹🧹\n\n"

cd terraform

if [ "$1" == "-y" ]; then
    terraform destroy -auto-approve
else
    terraform destroy ## will ask for confirmation
fi


printf "\n\n⚒️⚒️ Cluster deletion successfull !! ✅✅\n\n"