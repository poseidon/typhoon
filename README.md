# purenetes <img align="right" src="https://storage.googleapis.com/dghubble/spin.png">

* Minimal, stable base Kubernetes distribution
* Declarative infrastructure and configuration
* Practical for small labs to medium clusters
* 100% [free](https://www.debian.org/intro/free) components (both freedom and zero cost)
* Respect for privacy by requiring analytics be opt-in

## Status

Purenetes is [dghubble](https://twitter.com/dghubble)'s personal Kubernetes distribution. It powers his cloud and colocation clusters. While functional, it is not yet suited for the public.

## Features

* Kubernetes v1.7.1 with self-hosted control plane via [kubernetes-incubator/bootkube](https://github.com/kubernetes-incubator/bootkube)
* Secure etcd with generated TLS certs, [RBAC](https://kubernetes.io/docs/admin/authorization/rbac/)-enabled, generated admin kubeconfig
* Multi-master, workload isolation
* Ingress-ready (perhaps include by default)
* Works with your existing Terraform infrastructure and secret management

## Documentation

See [docs.purenetes.org](https://docs.purenetes.org)

## Modules

Purenetes provides a Terraform Module for each supported operating system and platform.

| Platform      | Operating System | Terraform Module |
|---------------|------------------|------------------|
| Bare-Metal    | Container Linux  | bare-metal/container-linux/kubernetes |
| Google Cloud  | Container Linux  | google-cloud/container-linux/kubernetes |
| Digital Ocean | Container Linux  | digital-ocean/container-linux/kubernetes |

## Customization

To customize clusters in ways that aren't supported by input variables, fork the repo and make changes to the Terraform module. Stay tuned for improvements to this strategy since its beneficial to stay close to this upstream.

To customize lower-level Kubernetes control plane bootstrapping, see the [purenetes/bootkube-terraform](https://github.com/purenetes/bootkube-terraform) Terraform module.

## Contributing

Currently, `purenetes` is the author's personal distribution of Kubernetes. It is focused on addressing the author's cluster needs and is not yet accepting sizable contributions. As the project matures, this contributing policy will be changed to reflect those of a community project.

## Social Contract

*A formal social contract is being drafted, inspired by the Debian [Social Contract](https://www.debian.org/social_contract).*

For now, know that `purenetes` is not a product, trial, or free-tier. It is not run by a company, it does not offer support or services, and it does not accept or make any money. It is not associated with any operating system or cloud platform vendors.

Disclosure: The author works for CoreOS, but that work is kept as separate as possible. Support for Fedora is planned to ensure no one distro is favored and because the author wants it.

## Non-Goals

* In-place Kubernetes upgrades (instead, deploy blue/green clusters and failover)
