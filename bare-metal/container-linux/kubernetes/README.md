# Typhoon

Typhoon is a minimal and free Kubernetes distribution.

* Minimal, stable base Kubernetes distribution
* Declarative infrastructure and configuration
* Free (freedom and cost) and privacy-respecting
* Practical for labs, datacenters, and clouds

Typhoon distributes upstream Kubernetes, architectural conventions, and cluster addons, much like a GNU/Linux distribution provides the Linux kernel and userspace components.

## Features

* Kubernetes v1.8.2 (upstream, via [kubernetes-incubator/bootkube](https://github.com/kubernetes-incubator/bootkube))
* Single or multi-master, workloads isolated on workers, [Calico](https://www.projectcalico.org/) or [flannel](https://github.com/coreos/flannel) networking
* On-cluster etcd with TLS, [RBAC](https://kubernetes.io/docs/admin/authorization/rbac/)-enabled, [network policy](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
* Ready for Ingress, Dashboards, Metrics, and other optional [addons](https://typhoon.psdn.io/addons/overview/)

## Docs

Please see the [official docs](https://typhoon.psdn.io) and the bare-metal [tutorial](https://typhoon.psdn.io/bare-metal/).

