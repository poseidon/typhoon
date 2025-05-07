# ARM64

Typhoon supports Kubernetes clusters with ARM64 controller or worker nodes on several platforms:

* AWS with Fedora CoreOS or Flatcar Linux
* Azure with Flatcar Linux

## AWS

Create a cluster on AWS with ARM64 controller and worker nodes. Container workloads must be `arm64` compatible and use `arm64` (or multi-arch) container images.

=== "Fedora CoreOS Cluster (arm64)"

    ```tf
    module "gravitas" {
      source = "git::https://github.com/poseidon/typhoon//aws/fedora-coreos/kubernetes?ref=v1.33.0"

      # AWS
      cluster_name = "gravitas"
      dns_zone     = "aws.example.com"
      dns_zone_id  = "Z3PAABBCFAKEC0"

      # instances
      controller_type = "t4g.small"
      controller_arch = "arm64"
      worker_count    = 2
      worker_type     = "t4g.small"
      worker_arch     = "arm64"
      worker_price    = "0.0168"

      # configuration
      ssh_authorized_key = "ssh-ed25519 AAAAB3Nz..."
    }
    ```

=== "Flatcar Linux Cluster (arm64)"

    ```tf
    module "gravitas" {
      source = "git::https://github.com/poseidon/typhoon//aws/flatcar-linux/kubernetes?ref=v1.33.0"

      # AWS
      cluster_name = "gravitas"
      dns_zone     = "aws.example.com"
      dns_zone_id  = "Z3PAABBCFAKEC0"

      # instances
      controller_type = "t4g.small"
      controller_arch = "arm64"
      worker_count    = 2
      worker_type     = "t4g.small"
      worker_arch     = "arm64"
      worker_price    = "0.0168"

      # configuration
      ssh_authorized_key = "ssh-ed25519 AAAAB3Nz..."
    }
    ```

Verify the cluster has only arm64 (`aarch64`) nodes. For Flatcar Linux, describe nodes.

```
$ kubectl get nodes -o wide
NAME             STATUS   ROLES    AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                        KERNEL-VERSION            CONTAINER-RUNTIME
ip-10-0-21-119   Ready    <none>   77s   v1.33.0   10.0.21.119   <none>        Fedora CoreOS 35.20211215.3.0   5.15.7-200.fc35.aarch64   containerd://1.5.8
ip-10-0-32-166   Ready    <none>   80s   v1.33.0   10.0.32.166   <none>        Fedora CoreOS 35.20211215.3.0   5.15.7-200.fc35.aarch64   containerd://1.5.8
ip-10-0-5-79     Ready    <none>   77s   v1.33.0   10.0.5.79     <none>        Fedora CoreOS 35.20211215.3.0   5.15.7-200.fc35.aarch64   containerd://1.5.8
```

## Azure

Create a cluster on Azure with ARM64 controller and worker nodes. Container workloads must be `arm64` compatible and use `arm64` (or multi-arch) container images.

```tf
module "ramius" {
  source = "git::https://github.com/poseidon/typhoon//azure/flatcar-linux/kubernetes?ref=v1.33.0"

  # Azure
  cluster_name   = "ramius"
  location       = "centralus"
  dns_zone       = "azure.example.com"
  dns_zone_group = "example-group"

  # instances
  controller_arch = "arm64"
  controller_type = "Standard_B2pls_v5"
  worker_count    = 2
  controller_arch = "arm64"
  worker_type     = "Standard_D2pls_v5"

  # configuration
  ssh_authorized_key = "ssh-rsa AAAAB3Nz..."
}
```

## Hybrid

Create a hybrid/mixed arch cluster by defining a cluster where [worker pool(s)](worker-pools.md#aws) have a different instance type architecture than controllers or other workers. Taints are added to aid in scheduling.

Here's an AWS example,

=== "FCOS Cluster"

    ```tf
    module "gravitas" {
      source = "git::https://github.com/poseidon/typhoon//aws/fedora-coreos/kubernetes?ref=v1.33.0"

      # AWS
      cluster_name = "gravitas"
      dns_zone     = "aws.example.com"
      dns_zone_id  = "Z3PAABBCFAKEC0"

      # instances
      worker_count = 2
      worker_arch  = "arm64"
      worker_type  = "t4g.medium"
      worker_price = "0.021"

      # configuration
      daemonset_tolerations = ["arch"]     # important
      networking            = "cilium"
      ssh_authorized_key    = "ssh-ed25519 AAAAB3Nz..."
    }
    ```

=== "Flatcar Cluster"

    ```tf
    module "gravitas" {
      source = "git::https://github.com/poseidon/typhoon//aws/flatcar-linux/kubernetes?ref=v1.33.0"

      # AWS
      cluster_name = "gravitas"
      dns_zone     = "aws.example.com"
      dns_zone_id  = "Z3PAABBCFAKEC0"

      # instances
      worker_count = 2
      worker_arch  = "arm64"
      worker_type  = "t4g.medium"
      worker_price = "0.021"

      # configuration
      daemonset_tolerations = ["arch"]     # important
      networking            = "cilium"
      ssh_authorized_key    = "ssh-ed25519 AAAAB3Nz..."
    }
    ```

=== "FCOS ARM64 Workers"

    ```tf
    module "gravitas-arm64" {
      source = "git::https://github.com/poseidon/typhoon//aws/fedora-coreos/kubernetes/workers?ref=v1.33.0"

      # AWS
      vpc_id          = module.gravitas.vpc_id
      subnet_ids      = module.gravitas.subnet_ids
      security_groups = module.gravitas.worker_security_groups

      # instances
      arch          = "arm64"
      instance_type = "t4g.small"
      spot_price    = "0.0168"

      # configuration
      name               = "gravitas-arm64"
      kubeconfig         = module.gravitas.kubeconfig
      node_taints        = ["arch=arm64:NoSchedule"]
      ssh_authorized_key = var.ssh_authorized_key
    }
    ```

=== "Flatcar ARM64 Workers"

    ```tf
    module "gravitas-arm64" {
      source = "git::https://github.com/poseidon/typhoon//aws/flatcar-linux/kubernetes/workers?ref=v1.33.0"

      # AWS
      vpc_id          = module.gravitas.vpc_id
      subnet_ids      = module.gravitas.subnet_ids
      security_groups = module.gravitas.worker_security_groups

      # instances
      arch          = "arm64"
      instance_type = "t4g.small"
      spot_price    = "0.0168"

      # configuration
      name               = "gravitas-arm64"
      kubeconfig         = module.gravitas.kubeconfig
      node_taints        = ["arch=arm64:NoSchedule"]
      ssh_authorized_key = var.ssh_authorized_key
    }
    ```

Verify amd64 (x86_64) and arm64 (aarch64) nodes are present.

```
$ kubectl get nodes -o wide
NAME                       STATUS   ROLES    AGE    VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                                             KERNEL-VERSION            CONTAINER-RUNTIME
ip-10-0-1-73               Ready    <none>   111m   v1.33.0   10.0.1.73     <none>        Fedora CoreOS 35.20211215.3.0                        5.15.7-200.fc35.x86_64    containerd://1.5.8
ip-10-0-22-79...           Ready    <none>   111m   v1.33.0   10.0.22.79    <none>        Flatcar Container Linux by Kinvolk 3033.2.0 (Oklo)   5.10.84-flatcar           containerd://1.5.8
ip-10-0-24-130             Ready    <none>   111m   v1.33.0   10.0.24.130   <none>        Fedora CoreOS 35.20211215.3.0                        5.15.7-200.fc35.x86_64    containerd://1.5.8
ip-10-0-39-19              Ready    <none>   111m   v1.33.0   10.0.39.19    <none>        Fedora CoreOS 35.20211215.3.0                        5.15.7-200.fc35.x86_64    containerd://1.5.8
```

