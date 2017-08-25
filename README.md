# Typhoon <img align="right" src="https://storage.googleapis.com/dghubble/spin.png">

Typhoon is a minimal and free Kubernetes distribution.

* Minimal, stable base Kubernetes distribution
* Declarative infrastructure and configuration
* [Free](#social-contract) (freedom and cost) and privacy-respecting
* Practical for labs, datacenters, and clouds

## Features

* Kubernetes v1.7.3 (upstream, via [kubernetes-incubator/bootkube](https://github.com/kubernetes-incubator/bootkube))
* Self-hosted control plane, single or multi master, workloads isolated to workers
* On-cluster etcd with TLS, [RBAC](https://kubernetes.io/docs/admin/authorization/rbac/)-enabled
* Ready for Ingress, Metrics, Dashboards, and other optional [addons](docs/addons.md)

## Modules

Typhoon provides a Terraform Module for each supported operating system and platform.

| Platform      | Operating System | Terraform Module |
|---------------|------------------|------------------|
| Bare-Metal    | Container Linux  | [bare-metal/container-linux/kubernetes](bare-metal/container-linux/kubernetes) |
| Digital Ocean | Container Linux  | [digital-ocean/container-linux/kubernetes](digital-ocean/container-linux/kubernetes) |
| Google Cloud  | Container Linux  | [google-cloud/container-linux/kubernetes](google-cloud/container-linux/kubernetes) |

## Docs

* [https://typhoon.psdn.io](https://typhoon.psdn.io)
* [Concepts](https://typhoon.psdn.io/concepts/)
* [Bare-Metal](https://typhoon.psdn.io/bare-metal/)
* [Digital Ocean](https://typhoon.psdn.io/digital-ocean/)
* [Google-Cloud](https://typhoon.psdn.io/google-cloud/)

## Example

Define a Kubernetes cluster by using the Terraform module for your chosen platform and operating system. Here's a minimal example:

```tf
module "yavin-cluster" {
  source = "git::https://github.com/poseidon/typhoon//google-cloud/container-linux/kubernetes"

  # Google Cloud
  zone               = "us-central1-c"
  dns_zone           = "example.com"
  dns_zone_name      = "example-zone"
  os_image           = "coreos-stable-1465-6-0-v20170817"
  
  # Cluster
  cluster_name       = "yavin"
  controller_count   = 1
  worker_count       = 2
  ssh_authorized_key = "${var.ssh_authorized_key}"

  # output assets dir
  asset_dir = "/home/user/.secrets/clusters/yavin"
}
```

Fetch modules, plan the changes to be made, and apply the changes.

```sh
$ terraform get --update
$ terraform plan
Plan: 37 to add, 0 to change, 0 to destroy.
$ terraform apply
Apply complete! Resources: 37 added, 0 changed, 0 destroyed.
```

In 5-10 minutes (varies by platform), the cluster will be ready. This Google Cloud example creates a `yavin.example.com` DNS record to resolve to a network load balancer across controller nodes.

```sh
$ KUBECONFIG=/home/user/.secrets/clusters/yavin/auth/kubeconfig
$ kubectl get nodes
NAME                                           STATUS  AGE  VERSION
yavin-controller-t6nx.c.example-com.internal   Ready   3m   v1.7.3+coreos.0
yavin-worker-gvhs.c.example-com.internal       Ready   3m   v1.7.3+coreos.0
yavin-worker-m8pl.c.example-com.internal       Ready   3m   v1.7.3+coreos.0
yavin-worker-wsg7.c.example-com.internal       Ready   3m   v1.7.3+coreos.0
```

```sh
$ kubectl get pods
NAME                                        READY    STATUS    RESTARTS   AGE
etcd-operator-3329263108-v34bb              1/1      Running   2          3m
kube-apiserver-qgqz5                        1/1      Running   1          3m
kube-controller-manager-3271970485-1jxgj    1/1      Running   1          3m
kube-controller-manager-3271970485-k57nb    1/1      Running   1          3m
kube-dns-1187388186-wz3c1                   3/3      Running   0          3m
kube-etcd-0000                              1/1      Running   1          3m
kube-etcd-network-checkpointer-3bv09        1/1      Running   1          3m
kube-flannel-8g1l1                          2/2      Running   1          3m
kube-flannel-bndl8                          2/2      Running   1          3m
kube-flannel-hvm8l                          2/2      Running   1          3m
kube-flannel-tfgj0                          2/2      Running   1          3m
kube-proxy-8bbkk                            1/1      Running   0          3m
kube-proxy-gwv6m                            1/1      Running   0          3m
kube-proxy-h9hnm                            1/1      Running   0          3m
kube-proxy-v9mlp                            1/1      Running   1          3m
kube-scheduler-3895335239-0fglg             1/1      Running   1          3m
kube-scheduler-3895335239-dpd66             1/1      Running   1          3m
pod-checkpointer-v2zmz                      1/1      Running   1          3m
```

## Non-Goals

Typhoon is strict about minimalism, maturity, and scope. These are not in scope:

* In-place Kubernetes Upgrades
* Adding every possible option
* Openstack or Mesos platforms

## Background

Typhoon powers the original author's cloud and colocation clusters. The project has been developed through operational experience and Kubernetes evolutions. In 2017, Typhoon was shared under a free license to allow others to use the work freely and contribute to its upkeep.

Typhoon clusters address real world needs, which you may share. We'll be honest about any limitations or areas that haven't been explored yet. We'll steer clear of buzzword bingo and hype. If your needs turn out to be different, we'll wish you the best of luck with another project.

## Social Contract

Typhoon is not a product, trial, or free-tier. It is not run by a company, does not offer support or services, and does not accept or make any money. It is not associated with operating system or platform vendors.

Typhoon clusters will contain only [free](https://www.debian.org/intro/free) components. Cluster components will not collect data on users without their permission.

*Disclosure: The author works for CoreOS and previously wrote Matchbox and early Tectonic for bare-metal and AWS.*
