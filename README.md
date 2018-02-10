# Typhoon [![IRC](https://img.shields.io/badge/freenode-%23typhoon-0099ef.svg)]() <img align="right" src="https://storage.googleapis.com/poseidon/typhoon-logo.png">

Typhoon is a minimal and free Kubernetes distribution.

* Minimal, stable base Kubernetes distribution
* Declarative infrastructure and configuration
* [Free](#social-contract) (freedom and cost) and privacy-respecting
* Practical for labs, datacenters, and clouds

Typhoon distributes upstream Kubernetes, architectural conventions, and cluster addons, much like a GNU/Linux distribution provides the Linux kernel and userspace components.

## Features <a href="https://www.cncf.io/certification/software-conformance/"><img align="right" src="https://storage.googleapis.com/poseidon/certified-kubernetes.png"></a>

* Kubernetes v1.9.3 (upstream, via [kubernetes-incubator/bootkube](https://github.com/kubernetes-incubator/bootkube))
* Single or multi-master, workloads isolated on workers, [Calico](https://www.projectcalico.org/) or [flannel](https://github.com/coreos/flannel) networking
* On-cluster etcd with TLS, [RBAC](https://kubernetes.io/docs/admin/authorization/rbac/)-enabled, [network policy](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
* Ready for Ingress, Dashboards, Metrics, and other optional [addons](https://typhoon.psdn.io/addons/overview/)

## Modules

Typhoon provides a Terraform Module for each supported operating system and platform.

| Platform      | Operating System | Terraform Module | Status |
|---------------|------------------|------------------|--------|
| AWS           | Container Linux  | [aws/container-linux/kubernetes](aws/container-linux/kubernetes) | beta |
| Bare-Metal    | Container Linux  | [bare-metal/container-linux/kubernetes](bare-metal/container-linux/kubernetes) | stable |
| Digital Ocean | Container Linux  | [digital-ocean/container-linux/kubernetes](digital-ocean/container-linux/kubernetes) | beta |
| Google Cloud  | Container Linux  | [google-cloud/container-linux/kubernetes](google-cloud/container-linux/kubernetes) | beta |

## Usage

* [Docs](https://typhoon.psdn.io)
* [Concepts](https://typhoon.psdn.io/concepts/)
* Tutorials
  * [AWS](https://typhoon.psdn.io/aws/)
  * [Bare-Metal](https://typhoon.psdn.io/bare-metal/)
  * [Digital Ocean](https://typhoon.psdn.io/digital-ocean/)
  * [Google-Cloud](https://typhoon.psdn.io/google-cloud/)

## Example

Define a Kubernetes cluster by using the Terraform module for your chosen platform and operating system. Here's a minimal example:

```tf
module "google-cloud-yavin" {
  source = "git::https://github.com/poseidon/typhoon//google-cloud/container-linux/kubernetes"
  
  providers = {
    google = "google.default"
    local = "local.default"
    null = "null.default"
    template = "template.default"
    tls = "tls.default"
  }

  # Google Cloud
  region        = "us-central1"
  dns_zone      = "example.com"
  dns_zone_name = "example-zone"
  os_image      = "coreos-stable-1576-5-0-v20180105"

  cluster_name       = "yavin"
  controller_count   = 1
  worker_count       = 2
  ssh_authorized_key = "ssh-rsa AAAAB3Nz..."

  # output assets dir
  asset_dir = "/home/user/.secrets/clusters/yavin"
}
```

Fetch modules, plan the changes to be made, and apply the changes.

```sh
$ terraform init
$ terraform get --update
$ terraform plan
Plan: 37 to add, 0 to change, 0 to destroy.
$ terraform apply
Apply complete! Resources: 37 added, 0 changed, 0 destroyed.
```

In 4-8 minutes (varies by platform), the cluster will be ready. This Google Cloud example creates a `yavin.example.com` DNS record to resolve to a network load balancer across controller nodes.

```sh
$ export KUBECONFIG=/home/user/.secrets/clusters/yavin/auth/kubeconfig
$ kubectl get nodes
NAME                                          STATUS   AGE    VERSION
yavin-controller-0.c.example-com.internal     Ready    6m     v1.9.3
yavin-worker-jrbf.c.example-com.internal      Ready    5m     v1.9.3
yavin-worker-mzdm.c.example-com.internal      Ready    5m     v1.9.3
```

List the pods.

```
$ kubectl get pods --all-namespaces
NAMESPACE     NAME                                      READY  STATUS    RESTARTS  AGE
kube-system   calico-node-1cs8z                         2/2    Running   0         6m
kube-system   calico-node-d1l5b                         2/2    Running   0         6m
kube-system   calico-node-sp9ps                         2/2    Running   0         6m
kube-system   kube-apiserver-zppls                      1/1    Running   0         6m
kube-system   kube-controller-manager-3271970485-gh9kt  1/1    Running   0         6m
kube-system   kube-controller-manager-3271970485-h90v8  1/1    Running   1         6m
kube-system   kube-dns-1187388186-zj5dl                 3/3    Running   0         6m
kube-system   kube-proxy-117v6                          1/1    Running   0         6m
kube-system   kube-proxy-9886n                          1/1    Running   0         6m
kube-system   kube-proxy-njn47                          1/1    Running   0         6m
kube-system   kube-scheduler-3895335239-5x87r           1/1    Running   0         6m
kube-system   kube-scheduler-3895335239-bzrrt           1/1    Running   1         6m
kube-system   pod-checkpointer-l6lrt                    1/1    Running   0         6m
```

## Non-Goals

Typhoon is strict about minimalism, maturity, and scope. These are not in scope:

* In-place Kubernetes Upgrades
* Adding every possible option
* Openstack or Mesos platforms

## Help

Ask questions on the IRC #typhoon channel on [freenode.net](http://freenode.net/).

## Background

Typhoon powers the author's cloud and colocation clusters. The project has evolved through operational experience and Kubernetes changes. Typhoon is shared under a free license to allow others to use the work freely and contribute to its upkeep.

Typhoon addresses real world needs, which you may share. It is honest about limitations or areas that aren't mature yet. It avoids buzzword bingo and hype. It does not aim to be the one-solution-fits-all distro. An ecosystem of free (or enterprise) Kubernetes distros is healthy.

## Social Contract

Typhoon is not a product, trial, or free-tier. It is not run by a company, does not offer support or services, and does not accept or make any money. It is not associated with any operating system or platform vendor.

Typhoon clusters will contain only [free](https://www.debian.org/intro/free) components. Cluster components will not collect data on users without their permission.

*Disclosure: The author works for Red Hat (prev CoreOS), but Typhoon is unassociated and maintained independently.*
