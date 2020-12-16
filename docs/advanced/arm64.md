# ARM64

!!! warning
    ARM64 support is experimental

Typhoon has experimental support for ARM64 with Fedora CoreOS on AWS. Full clusters can be created with ARM64 controller and worker nodes. Or worker pools of ARM64 nodes can be attached to an AMD64 cluster to create a hybrid/mixed architecture cluster.

!!! note
    Currently, CNI networking must be set to flannel.

## AMIs

In lieu of official Fedora CoreOS ARM64 AMIs, Poseidon publishes experimental ARM64 AMIs to a few regions (us-east-1, us-east-2, us-west-1). These AMIs may be **removed** at any time and will be replaced when Fedora CoreOS publishes equivalents.

!!! note
    AMIs are only published to a few regions, and AWS availability of ARM instance types varies.

## Cluster

Create a cluster with ARM64 controller and worker nodes. Container workloads must be `arm64` compatible and use `arm64` container images.

```tf
module "gravitas" {
  source = "git::https://github.com/poseidon/typhoon//aws/fedora-coreos/kubernetes?ref=v1.19.4"

  # AWS
  cluster_name = "gravitas"
  dns_zone     = "aws.example.com"
  dns_zone_id  = "Z3PAABBCFAKEC0"

  # configuration
  ssh_authorized_key = "ssh-rsa AAAAB3Nz..."

  # optional
  arch         = "arm64"
  networking   = "flannel"
  worker_count = 2
  worker_price = "0.0168"

  controller_type = "t4g.small"
  worker_type     = "t4g.small"
}
```

Verify the cluster has only arm64 (`aarch64`) nodes.

```
$ kubectl get nodes -o wide
NAME             STATUS   ROLES    AGE    VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                          KERNEL-VERSION            CONTAINER-RUNTIME
ip-10-0-12-178   Ready    <none>   101s   v1.19.4   10.0.12.178   <none>        Fedora CoreOS 32.20201104.dev.0   5.8.17-200.fc32.aarch64   docker://19.3.11
ip-10-0-18-93    Ready    <none>   102s   v1.19.4   10.0.18.93    <none>        Fedora CoreOS 32.20201104.dev.0   5.8.17-200.fc32.aarch64   docker://19.3.11
ip-10-0-90-10    Ready    <none>   104s   v1.19.4   10.0.90.10    <none>        Fedora CoreOS 32.20201104.dev.0   5.8.17-200.fc32.aarch64   docker://19.3.11
```

## Hybrid

Create a hybrid/mixed arch cluster by defining an AWS cluster. Then define a [worker pool](worker-pools.md#aws) with ARM64 workers. Optional taints are added to aid in scheduling.

=== "Cluster (amd64)"

    ```tf
    module "gravitas" {
      source = "git::https://github.com/poseidon/typhoon//aws/fedora-coreos/kubernetes?ref=v1.19.4"

      # AWS
      cluster_name = "gravitas"
      dns_zone     = "aws.example.com"
      dns_zone_id  = "Z3PAABBCFAKEC0"

      # configuration
      ssh_authorized_key = "ssh-rsa AAAAB3Nz..."

      # optional
      networking   = "flannel"
      worker_count = 2
      worker_price = "0.021"

      daemonset_tolerations = ["arch"]     # important
    }
    ```

=== "Worker Pool (arm64)"

    ```tf
    module "gravitas-arm64" {
      source = "git::https://github.com/poseidon/typhoon//aws/fedora-coreos/kubernetes/workers?ref=v1.19.4"

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
NAME             STATUS   ROLES    AGE    VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                          KERNEL-VERSION            CONTAINER-RUNTIME
ip-10-0-14-73    Ready    <none>   116s   v1.19.4   10.0.14.73    <none>        Fedora CoreOS 32.20201018.3.0     5.8.15-201.fc32.x86_64    docker://19.3.11
ip-10-0-17-167   Ready    <none>   104s   v1.19.4   10.0.17.167   <none>        Fedora CoreOS 32.20201018.3.0     5.8.15-201.fc32.x86_64    docker://19.3.11
ip-10-0-47-166   Ready    <none>   110s   v1.19.4   10.0.47.166   <none>        Fedora CoreOS 32.20201104.dev.0   5.8.17-200.fc32.aarch64   docker://19.3.11
ip-10-0-7-237    Ready    <none>   111s   v1.19.4   10.0.7.237    <none>        Fedora CoreOS 32.20201018.3.0     5.8.15-201.fc32.x86_64    docker://19.3.11
```

