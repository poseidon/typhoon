# Typhoon <img align="right" src="https://storage.googleapis.com/poseidon/typhoon-logo.png">

Typhoon is a minimal and free Kubernetes distribution.

* Minimal, stable base Kubernetes distribution
* Declarative infrastructure and configuration
* Free (freedom and cost) and privacy-respecting
* Practical for labs, datacenters, and clouds

Typhoon distributes upstream Kubernetes, architectural conventions, and cluster addons, much like a GNU/Linux distribution provides the Linux kernel and userspace components.

## Features <a href="https://www.cncf.io/certification/software-conformance/"><img align="right" src="https://storage.googleapis.com/poseidon/certified-kubernetes.png"></a>

* Kubernetes v1.20.5 (upstream)
* Single or multi-master, [Calico](https://www.projectcalico.org/) or [Cilium](https://github.com/cilium/cilium) or [flannel](https://github.com/coreos/flannel) networking
* On-cluster etcd with TLS, [RBAC](https://kubernetes.io/docs/admin/authorization/rbac/)-enabled, [network policy](https://kubernetes.io/docs/concepts/services-networking/network-policies/), SELinux enforcing
* Advanced features like [worker pools](https://typhoon.psdn.io/advanced/worker-pools/), [spot priority](https://typhoon.psdn.io/fedora-coreos/azure/#low-priority) workers, and [snippets](https://typhoon.psdn.io/advanced/customization/#hosts) customization
* Ready for Ingress, Prometheus, Grafana, and other optional [addons](https://typhoon.psdn.io/addons/overview/)

## Docs

Please see the [official docs](https://typhoon.psdn.io) and the Azure [tutorial](https://typhoon.psdn.io/fedora-coreos/azure/).

