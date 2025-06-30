# Typhoon

[![Release](https://img.shields.io/github/v/release/poseidon/typhoon?style=flat-square)](https://github.com/poseidon/typhoon/releases)
[![Stars](https://img.shields.io/github/stars/poseidon/typhoon?style=flat-square)](https://github.com/poseidon/typhoon/stargazers)
[![Sponsors](https://img.shields.io/github/sponsors/poseidon?logo=github&style=flat-square)](https://github.com/sponsors/poseidon)
[![Mastodon](https://img.shields.io/badge/follow-news-6364ff?logo=mastodon&style=flat-square)](https://fosstodon.org/@typhoon)

<img align="right" src="https://storage.googleapis.com/poseidon/typhoon-logo.png">

Typhoon is a minimal and free Kubernetes distribution.

* Minimal, stable base Kubernetes distribution
* Declarative infrastructure and configuration
* [Free](#social-contract) (freedom and cost) and privacy-respecting
* Practical for labs, datacenters, and clouds

Typhoon distributes upstream Kubernetes, architectural conventions, and cluster addons, much like a GNU/Linux distribution provides the Linux kernel and userspace components.

## Features <a href="https://www.cncf.io/certification/software-conformance/"><img align="right" src="https://storage.googleapis.com/poseidon/certified-kubernetes.png"></a>

* Kubernetes v1.33.2 (upstream)
* Single or multi-master, [Cilium](https://github.com/cilium/cilium) or [flannel](https://github.com/coreos/flannel) networking
* On-cluster etcd with TLS, [RBAC](https://kubernetes.io/docs/admin/authorization/rbac/)-enabled, [network policy](https://kubernetes.io/docs/concepts/services-networking/network-policies/), SELinux enforcing
* Advanced features like [worker pools](https://typhoon.psdn.io/advanced/worker-pools/), [preemptible](https://typhoon.psdn.io/flatcar-linux/google-cloud/#preemption) workers, and [snippets](https://typhoon.psdn.io/advanced/customization/#hosts) customization
* Ready for Ingress, Prometheus, Grafana, CSI, or other [addons](https://typhoon.psdn.io/addons/overview/)

## Modules

Typhoon provides a Terraform Module for defining a Kubernetes cluster on each supported operating system and platform.

Typhoon is available for [Fedora CoreOS](https://getfedora.org/coreos/).

| Platform      | Operating System | Terraform Module | Status |
|---------------|------------------|------------------|--------|
| AWS           | Fedora CoreOS | [aws/fedora-coreos/kubernetes](aws/fedora-coreos/kubernetes) | stable |
| Azure         | Fedora CoreOS | [azure/fedora-coreos/kubernetes](azure/fedora-coreos/kubernetes) | alpha |
| Bare-Metal    | Fedora CoreOS | [bare-metal/fedora-coreos/kubernetes](bare-metal/fedora-coreos/kubernetes) | stable |
| DigitalOcean  | Fedora CoreOS | [digital-ocean/fedora-coreos/kubernetes](digital-ocean/fedora-coreos/kubernetes) | beta |
| Google Cloud  | Fedora CoreOS | [google-cloud/fedora-coreos/kubernetes](google-cloud/fedora-coreos/kubernetes) | stable |

| Platform      | Operating System | Terraform Module | Status |
|---------------|------------------|------------------|--------|
| AWS           | Fedora CoreOS (ARM64) | [aws/fedora-coreos/kubernetes](aws/fedora-coreos/kubernetes) | alpha |

Typhoon is available for [Flatcar Linux](https://www.flatcar-linux.org/releases/).

| Platform      | Operating System | Terraform Module | Status |
|---------------|------------------|------------------|--------|
| AWS           | Flatcar Linux    | [aws/flatcar-linux/kubernetes](aws/flatcar-linux/kubernetes) | stable |
| Azure         | Flatcar Linux    | [azure/flatcar-linux/kubernetes](azure/flatcar-linux/kubernetes) | alpha |
| Bare-Metal    | Flatcar Linux    | [bare-metal/flatcar-linux/kubernetes](bare-metal/flatcar-linux/kubernetes) | stable |
| DigitalOcean | Flatcar Linux  | [digital-ocean/flatcar-linux/kubernetes](digital-ocean/flatcar-linux/kubernetes) | beta |
| Google Cloud  | Flatcar Linux  | [google-cloud/flatcar-linux/kubernetes](google-cloud/flatcar-linux/kubernetes) | stable |

| Platform      | Operating System | Terraform Module | Status |
|---------------|------------------|------------------|--------|
| AWS           | Flatcar Linux (ARM64) | [aws/flatcar-linux/kubernetes](aws/flatcar-linux/kubernetes) | alpha |
| Azure         | Flatcar Linux (ARM64) | [azure/flatcar-linux/kubernetes](azure/flatcar-linux/kubernetes) | alpha |

Typhoon also provides Terraform Modules for optionally managing individual components applied onto clusters.

| Name    | Terraform Module | Status |
|---------|------------------|--------|
| CoreDNS | [addons/coredns](addons/coredns) | beta |
| Cilium  | [addons/cilium](addons/cilium) | beta |
| flannel | [addons/flannel](addons/flannel) | beta |

## Documentation

* [Docs](https://typhoon.psdn.io)
* Architecture [concepts](https://typhoon.psdn.io/architecture/concepts/) and [operating systems](https://typhoon.psdn.io/architecture/operating-systems/)
* Fedora CoreOS tutorials for [AWS](docs/fedora-coreos/aws.md), [Azure](docs/fedora-coreos/azure.md), [Bare-Metal](docs/fedora-coreos/bare-metal.md), [DigitalOcean](docs/fedora-coreos/digitalocean.md), and [Google Cloud](docs/fedora-coreos/google-cloud.md)
* Flatcar Linux tutorials for [AWS](docs/flatcar-linux/aws.md), [Azure](docs/flatcar-linux/azure.md), [Bare-Metal](docs/flatcar-linux/bare-metal.md), [DigitalOcean](docs/flatcar-linux/digitalocean.md), and [Google Cloud](docs/flatcar-linux/google-cloud.md)

## Usage

Define a Kubernetes cluster by using the Terraform module for your chosen platform and operating system. Here's a minimal example:

```tf
module "yavin" {
  source = "git::https://github.com/poseidon/typhoon//google-cloud/fedora-coreos/kubernetes?ref=v1.33.2"

  # Google Cloud
  cluster_name  = "yavin"
  region        = "us-central1"
  dns_zone      = "example.com"
  dns_zone_name = "example-zone"

  # configuration
  ssh_authorized_key = "ssh-ed25519 AAAAB3Nz..."

  # optional
  worker_count = 2
  worker_preemptible = true
}

# Obtain cluster kubeconfig
resource "local_file" "kubeconfig-yavin" {
  content         = module.yavin.kubeconfig-admin
  filename        = "/home/user/.kube/configs/yavin-config"
  file_permission = "0600"
}
```

Initialize modules, plan the changes to be made, and apply the changes.

```sh
$ terraform init
$ terraform plan
Plan: 62 to add, 0 to change, 0 to destroy.
$ terraform apply
Apply complete! Resources: 62 added, 0 changed, 0 destroyed.
```

In 4-8 minutes (varies by platform), the cluster will be ready. This Google Cloud example creates a `yavin.example.com` DNS record to resolve to a network load balancer across controller nodes.

```sh
$ export KUBECONFIG=/home/user/.kube/configs/yavin-config
$ kubectl get nodes
NAME                                       ROLES    STATUS  AGE  VERSION
yavin-controller-0.c.example-com.internal  <none>   Ready   6m   v1.33.2
yavin-worker-jrbf.c.example-com.internal   <none>   Ready   5m   v1.33.2
yavin-worker-mzdm.c.example-com.internal   <none>   Ready   5m   v1.33.2
```

List the pods.

```
$ kubectl get pods --all-namespaces
NAMESPACE     NAME                                      READY  STATUS    RESTARTS  AGE
kube-system   cilium-1cs8z                              1/1    Running   0         6m
kube-system   cilium-d1l5b                              1/1    Running   0         6m
kube-system   cilium-sp9ps                              1/1    Running   0         6m
kube-system   cilium-operator-68d778b448-g744f          1/1    Running   0         6m
kube-system   coredns-1187388186-zj5dl                  1/1    Running   0         6m
kube-system   coredns-1187388186-dkh3o                  1/1    Running   0         6m
kube-system   kube-apiserver-controller-0               1/1    Running   0         6m
kube-system   kube-controller-manager-controller-0      1/1    Running   0         6m
kube-system   kube-proxy-117v6                          1/1    Running   0         6m
kube-system   kube-proxy-9886n                          1/1    Running   0         6m
kube-system   kube-proxy-njn47                          1/1    Running   0         6m
kube-system   kube-scheduler-controller-0               1/1    Running   0         6m
```

## Non-Goals

Typhoon is strict about minimalism, maturity, and scope. These are not in scope:

* In-place Kubernetes Upgrades
* Adding every possible option
* Openstack or Mesos platforms

## Help

Schedule a meeting via [Github Sponsors](https://github.com/sponsors/poseidon?frequency=one-time) to discuss your use case.

## Motivation

Typhoon powers the author's cloud and colocation clusters. The project has evolved through operational experience and Kubernetes changes. Typhoon is shared under a free license to allow others to use the work freely and contribute to its upkeep.

Typhoon addresses real world needs, which you may share. It is honest about limitations or areas that aren't mature yet. It avoids buzzword bingo and hype. It does not aim to be the one-solution-fits-all distro. An ecosystem of Kubernetes distributions is healthy.

## Social Contract

Typhoon is not a product, trial, or free-tier. Typhoon does not offer support, services, or charge money. And Typhoon is independent of operating system or platform vendors.

Typhoon clusters will contain only [free](https://www.debian.org/intro/free) components. Cluster components will not collect data on users without their permission.

## Sponsors

Poseidon's Github [Sponsors](https://github.com/sponsors/poseidon) support the infrastructure and operational costs of providing Typhoon.

<a href="https://www.digitalocean.com/">
    <img src="https://opensource.nyc3.cdn.digitaloceanspaces.com/attribution/assets/SVG/DO_Logo_horizontal_blue.svg" width="201px">
</a>
<br>
<br>

<a href="https://deploy.equinix.com/">
  <img src="https://storage.googleapis.com/poseidon/equinix.png" width="201px">
</a>
<br>
<br>

If you'd like your company here, please contact dghubble at psdn.io.
