# 🚀 Instant-K8s-Cluster

Run a **full Kubernetes cluster** on AWS with **just a single command**.  
No manual setup — everything automated using **Terraform + Ansible + Bash**. 

**Purpose of this:** Learning and experimenting with kubernetes without much admin effort


### 📑 Navigation
- [Pre-Requisites](#pre-requisites)
 - [Running Cluster](#running-cluster)
- [Folder Structure](#folder-structure)
- [Configuring Cluster (dynamically)](#configuring-cluster-dynamically)
 - [What if Control Plane Restarts](#what-if-control-plane-restarts)
 - [Deleting Cluster](#deleting-cluster)
- [Minor details](#minor-details)

---

## Pre-Requisites

Before running the cluster, make sure you have:

1. A Linux machine  
2. AWS CLI installed  
3. Terraform installed  
4. Ansible installed  
5. AWS Access Keys created for your user  
6. Private/Public SSH keys setup ([See SSH Keys section](#ssh-keys))  

---

## Running Cluster

Running your cluster is super simple:

1. Configure AWS CLI:  

    ```bash
    aws configure
    ```

   Provide your **Access Key ID** & **Secret Access Key**.

2. Change into the project directory:

    ```bash
    cd instant-k8s-cluster
    ```

3. Make the shell scripts executable (one-time):

    ```bash
    chmod +x ./*.sh
    ```

4. From the **root folder**, run:

    ```bash
    ./create_cluster.sh
    ```

That’s it ✅
This script will:

* Initialize Terraform (if not already done)
* Generate dynamic Ansible inventory
* Execute Ansible playbooks
* Update your **local kubeconfig** automatically

Then run the below command for validation:
```bash
kubectl get nodes;
```

---

## Folder Structure

```text
root
  ├── ansible
  ├── terraform
  ├── scripts
  ├── create_cluster.sh
  ├── destroy_cluster.sh
  └── update_kubeconfig.sh
```

* 📁 **ansible/** → contains playbooks
* 📁 **terraform/** → contains `.tf` files
* 📁 **scripts/** → scripts executed on control plane & worker nodes
* 📜 **create\_cluster.sh** → creates the cluster
* 📜 **destroy\_cluster.sh** → deletes the cluster
* 📜 **update\_kubeconfig.sh** → updates kubeconfig on reboot

---

## Configuring Cluster (dynamically)

The cluster is **fully configurable** 🎛️

* **Update Kubernetes version** → edit `K8S_VERSION` in `scripts/base.sh`
* **Change worker node count** → edit `total_worker_instances` in `terraform/variables.tf`
* **Change instance type** → edit `controlplane_instance_type` and `worker_instance_type` in `terraform/variables.tf`
* **SSH access to control plane and worker node**
  * Control plane SSH → update `ssh_from_ip` in `terraform/variables.tf`
  * Worker node SSH → update `my_ip_cidr` in the `locals` block of `terraform/variables.tf`
* **API server communication access (port 6443)** → update `my_ip_cidr` in the `locals` block of `terraform/variables.tf`

Tip: You can adjust security group rules later in the AWS Console, but making changes via Terraform variables keeps the setup reproducible and automated.

### SSH Keys

* By default, the setup expects:

  * Private key → `~/.ssh/ec2`
  * Public key → `~/.ssh/ec2.pub`

* To change paths → update `public/private_key_path` in `terraform/variables.tf`

Generate keys using:

```bash
ssh-keygen
```

⚠️ Do **not** use passphrases.

---

## What if Control Plane Restarts

If the **control plane instance restarts**:

* The public IP changes
* The Kubernetes API server certificate becomes invalid
* Your `kubectl` commands won’t work due to failed host validation

✅ The good part — the setup **automatically regenerates certificates** on reboot (see `scripts/on_restart.sh` & `scripts/controlplane.sh` for checking how it do automatically).

👉 You just need to run one command on your local machine:

```bash
./update_kubeconfig.sh
```

This updates kubeconfig with the **new API server IP & certificates**.

Done — you’re back online

---

## Deleting Cluster

To delete the cluster, run:

```bash
./destroy_cluster.sh
```

It will ask for manual confirmation.

If you prefer **auto-delete without confirmation**:

```bash
./destroy_cluster.sh -y
```

---

## Summary

* ✅ One-command Kubernetes cluster setup on AWS
* ⚡ Fully automated with Terraform & Ansible
* 🔧 Easy configuration (K8s version, instance type, worker count, etc.)
* ♻️ Self-healing API server certs on reboot
* 🗑️ Clean and quick teardown

---

## Minor details

1. Re-running `create_cluster.sh` is safe: it checks Terraform state and exits if the cluster already exists, avoiding duplicate provisioning.

<br>

2. Worker nodes auto-join the control plane using a dynamically generated `joinNodes.sh` script (rendered by Ansible).

<br>

3. Ansible inventory is generated after Terraform creates resources. To change the number of worker nodes, update `variables.tf`; the workflow handles it automatically.

<br>

4. Playbooks aren’t fully idempotent because they execute Bash scripts on the control plane and worker nodes.

<br>

5. Terraform provisions resources in the default VPC. For stronger isolation, add Terraform networking for a dedicated VPC, subnets, and security groups, (For basic setup the default one is fine)

<br>

6. `update_kubeconfig.sh` relies on the control plane instance’s `Name` tag. If you change the name in `terraform/compute.tf`, update the script accordingly. (Recommended: Don't change the Name tag of control plane instance at all)

<br>

7. `on_restart.sh` is installed on the control plane as a systemd service and runs on every reboot to refresh the API server certificate and kubeconfig.

<br>

8. The current setup uses Flannel CNI
