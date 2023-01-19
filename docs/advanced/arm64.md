# ARM64

Typhoon supports ARM64 Kubernetes clusters with ARM64 controller and worker nodes (full-cluster) or adding worker pools of ARM64 nodes to clusters with an x86/amd64 control plane for a hybdrid (mixed-arch) cluster.

Typhoon ARM64 clusters (full-cluster or mixed-arch) are available on:

* AWS with Fedora CoreOS or Flatcar Linux
* Azure with Flatcar Linux

## Cluster

Create a cluster on AWS with ARM64 controller and worker nodes. Container workloads must be `arm64` compatible and use `arm64` (or multi-arch) container images.

=== "Fedora CoreOS Cluster (arm64)"

    ```tf
    module "gravitas" {
      source = "git::https://github.com/poseidon/typhoon//aws/fedora-coreos/kubernetes?ref=v1.26.1"

      # AWS
      cluster_name = "gravitas"
      dns_zone     = "aws.example.com"
      dns_zone_id  = "Z3PAABBCFAKEC0"

      # configuration
      ssh_authorized_key = "ssh-ed25519 AAAAB3Nz..."

      # optional
      arch         = "arm64"
      networking   = "cilium"
      worker_count = 2
      worker_price = "0.0168"

      controller_type = "t4g.small"
      worker_type     = "t4g.small"
    }
    ```

=== "Flatcar Linux Cluster (arm64)"

    ```tf
    module "gravitas" {
      source = "git::https://github.com/poseidon/typhoon//aws/flatcar-linux/kubernetes?ref=v1.26.1"

      # AWS
      cluster_name = "gravitas"
      dns_zone     = "aws.example.com"
      dns_zone_id  = "Z3PAABBCFAKEC0"

      # configuration
      ssh_authorized_key = "ssh-ed25519 AAAAB3Nz..."

      # optional
      arch         = "arm64"
      networking   = "cilium"
      worker_count = 2
      worker_price = "0.0168"

      controller_type = "t4g.small"
      worker_type     = "t4g.small"
    }
    ```

Verify the cluster has only arm64 (`aarch64`) nodes. For Flatcar Linux, describe nodes.

```
$ kubectl get nodes -o wide
NAME             STATUS   ROLES    AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                        KERNEL-VERSION            CONTAINER-RUNTIME
ip-10-0-21-119   Ready    <none>   77s   v1.26.1   10.0.21.119   <none>        Fedora CoreOS 35.20211215.3.0   5.15.7-200.fc35.aarch64   containerd://1.5.8
ip-10-0-32-166   Ready    <none>   80s   v1.26.1   10.0.32.166   <none>        Fedora CoreOS 35.20211215.3.0   5.15.7-200.fc35.aarch64   containerd://1.5.8
ip-10-0-5-79     Ready    <none>   77s   v1.26.1   10.0.5.79     <none>        Fedora CoreOS 35.20211215.3.0   5.15.7-200.fc35.aarch64   containerd://1.5.8
```

## Hybrid

Create a hybrid/mixed arch cluster by defining an AWS cluster. Then define a [worker pool](worker-pools.md#aws) with ARM64 workers. Optional taints are added to aid in scheduling.

=== "FCOS Cluster"

    ```tf
    module "gravitas" {
      source = "git::https://github.com/poseidon/typhoon//aws/fedora-coreos/kubernetes?ref=v1.26.1"

      # AWS
      cluster_name = "gravitas"
      dns_zone     = "aws.example.com"
      dns_zone_id  = "Z3PAABBCFAKEC0"

      # configuration
      ssh_authorized_key = "ssh-ed25519 AAAAB3Nz..."

      # optional
      networking   = "cilium"
      worker_count = 2
      worker_price = "0.021"

      daemonset_tolerations = ["arch"]     # important
    }
    ```

=== "Flatcar Cluster"

    ```tf
    module "gravitas" {
      source = "git::https://github.com/poseidon/typhoon//aws/flatcar-linux/kubernetes?ref=v1.26.1"

      # AWS
      cluster_name = "gravitas"
      dns_zone     = "aws.example.com"
      dns_zone_id  = "Z3PAABBCFAKEC0"

      # configuration
      ssh_authorized_key = "ssh-ed25519 AAAAB3Nz..."

      # optional
      networking   = "cilium"
      worker_count = 2
      worker_price = "0.021"

      daemonset_tolerations = ["arch"]     # important
    }
    ```

=== "FCOS ARM64 Workers"

    ```tf
    module "gravitas-arm64" {
      source = "git::https://github.com/poseidon/typhoon//aws/fedora-coreos/kubernetes/workers?ref=v1.26.1"

      # AWS
      vpc_id          = module.gravitas.vpc_id
      subnet_ids      = module.gravitas.subnet_ids
      security_groups = module.gravitas.worker_security_groups

      # configuration
      name               = "gravitas-arm64"
      kubeconfig         = module.gravitas.kubeconfig
      ssh_authorized_key = var.ssh_authorized_key

      # optional
      arch          = "arm64"
      instance_type = "t4g.small"
      spot_price    = "0.0168"
      node_taints   = ["arch=arm64:NoSchedule"]
    }
    ```

=== "Flatcar ARM64 Workers"

    ```tf
    module "gravitas-arm64" {
      source = "git::https://github.com/poseidon/typhoon//aws/flatcar-linux/kubernetes/workers?ref=v1.26.1"

      # AWS
      vpc_id          = module.gravitas.vpc_id
      subnet_ids      = module.gravitas.subnet_ids
      security_groups = module.gravitas.worker_security_groups

      # configuration
      name               = "gravitas-arm64"
      kubeconfig         = module.gravitas.kubeconfig
      ssh_authorized_key = var.ssh_authorized_key

      # optional
      arch          = "arm64"
      instance_type = "t4g.small"
      spot_price    = "0.0168"
      node_taints   = ["arch=arm64:NoSchedule"]
    }
    ```

Verify amd64 (x86_64) and arm64 (aarch64) nodes are present.

```
$ kubectl get nodes -o wide
NAME                       STATUS   ROLES    AGE    VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                                             KERNEL-VERSION            CONTAINER-RUNTIME
ip-10-0-1-73               Ready    <none>   111m   v1.26.1   10.0.1.73     <none>        Fedora CoreOS 35.20211215.3.0                        5.15.7-200.fc35.x86_64    containerd://1.5.8
ip-10-0-22-79...           Ready    <none>   111m   v1.26.1   10.0.22.79    <none>        Flatcar Container Linux by Kinvolk 3033.2.0 (Oklo)   5.10.84-flatcar           containerd://1.5.8
ip-10-0-24-130             Ready    <none>   111m   v1.26.1   10.0.24.130   <none>        Fedora CoreOS 35.20211215.3.0                        5.15.7-200.fc35.x86_64    containerd://1.5.8
ip-10-0-39-19              Ready    <none>   111m   v1.26.1   10.0.39.19    <none>        Fedora CoreOS 35.20211215.3.0                        5.15.7-200.fc35.x86_64    containerd://1.5.8
```

## Azure

Create a cluster on Azure with ARM64 controller and worker nodes. Container workloads must be `arm64` compatible and use `arm64` (or multi-arch) container images.

```tf
module "ramius" {
  source = "git::https://github.com/poseidon/typhoon//azure/flatcar-linux/kubernetes?ref=v1.26.1"

  # Azure
  cluster_name   = "ramius"
  region         = "centralus"
  dns_zone       = "azure.example.com"
  dns_zone_group = "example-group"

  # configuration
  ssh_authorized_key = "ssh-rsa AAAAB3Nz..."

  # optional
  arch            = "arm64"
  controller_type = "Standard_D2pls_v5"
  worker_type     = "Standard_D2pls_v5"
  worker_count    = 2
  host_cidr       = "10.0.0.0/20"
}
```
