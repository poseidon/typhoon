# Announce <img align="right" src="https://storage.googleapis.com/poseidon/typhoon-logo-small.png">

## May 23, 2018

Starting in v1.10.3, Typhoon AWS and bare-metal `container-linux` modules allow picking between the Red Hat [Container Linux](https://coreos.com/os/docs/latest/) (formerly CoreOS Container Linux) and Kinvolk [Flatcar Linux](https://www.flatcar-linux.org/) operating system. Flatcar Linux serves as a drop-in compatible "friendly fork" of Container Linux. Flatcar Linux publishes the same channels and versions as Container Linux and gets provisioned, managed, and operated in an identical way (e.g. login as user "core").

On AWS, pick the Container Linux derivative channel by setting `os_image` to coreos-stable, coreos-beta, coreos-alpha, flatcar-stable, flatcar-beta, or flatcar-alpha.

On bare-metal, pick the Container Linux derivative channel by setting `os_channel` to coreos-stable, coreos-beta, coreos-alpha, flatcar-stable, flatcar-beta, or flatcar-alpha. Set the `os_version` number to PXE boot and install. Variables `container_linux_channel` and `container_linux_version` have been dropped.

Flatcar Linux provides a familar Container Linux experience, with support from Kinvolk as an alternative to Red Hat. Typhoon offers the choice of Container Linux vendor to satisfy differing preferences and to diversify technology underpinnings, while providing a consistent Kubernetes experience across operating systems, clouds, and on-premise.

## April 26, 2018

Introducing Typhoon Kubernetes clusters for Fedora Atomic!

Fedora Atomic is a container-optimized operating system designed for large-scale clustered operation, immutable infrastructure, and atomic operating system upgrades. Its part of [Fedora](https://getfedora.org/en/atomic/download/) and [Project Atomic](http://www.projectatomic.io/docs/introduction/), a Red Hat sponsored project working on rpm-ostree, buildah, skopeo, CRI-O, and the related CentOS/RHEL Atomic.

For newcomers, Typhoon is a free (cost and freedom) Kubernetes distribution providing upstream Kubernetes, declarative configuration via [Terraform](https://www.terraform.io/intro/index.html), and support for AWS, Google Cloud, DigitalOcean, and bare-metal. Typhoon clusters use a [self-hosted](https://github.com/kubernetes-incubator/bootkube) control plane, support [Calico](https://www.projectcalico.org/blog/) and [flannel](https://coreos.com/flannel/docs/latest/) CNI networking, and enable etcd TLS, [RBAC](https://kubernetes.io/docs/admin/authorization/rbac/), and network policy.

Typhoon for Fedora Atomic reflects many of the same principles that created Typhoon for Container Linux. Clusters are declared using plain Terraform configs that can be versioned. In lieu of Ignition, instances are declaratively provisioned with Cloud-Init and kickstart (bare-metal only). TLS assets are generated. Hosts run only a kubelet service, other components are scheduled (i.e. self-hosted). The upstream hyperkube is used directly[^1]. And clusters are kept minimal by offering optional addons for [Ingress](https://typhoon.psdn.io/addons/ingress/), [Prometheus](https://typhoon.psdn.io/addons/prometheus/), and [Grafana](https://typhoon.psdn.io/addons/grafana/). Typhoon compliments and enhances Fedora Atomic as a choice of operating system for Kubernetes.

Meanwhile, Fedora Atomic adds some promising new low-level technologies:

* [ostree](https://github.com/ostreedev/ostree) & [rpm-ostree](https://github.com/projectatomic/rpm-ostree) - a hybrid, layered, image and package system that lets you perform atomic updates and rollbacks, layer on packages, "rebase" your system, or manage a remote tree repo. See Dusty Mabe's great [intro](https://dustymabe.com/2017/09/01/atomic-host-101-lab-part-3-rebase-upgrade-rollback/). 

* [system containers](http://www.projectatomic.io/blog/2016/09/intro-to-system-containers/) - OCI container images that embed systemd and runc metadata for starting low-level host services before container runtimes are ready. Typhoon uses system containers under runc for `etcd`, `kubelet`, and `bootkube` on Fedora Atomic (instead of rkt-fly).

* [CRI-O](https://github.com/kubernetes-incubator/cri-o) - CRI-O is a kubernetes-incubator implementation of the Kubernetes Container Runtime Interface. Typhoon uses Docker as the container runtime today, but its a goal to gradually introduce CRI-O as an alternative runtime as it matures.

Typhoon has long [aspired](https://github.com/poseidon/typhoon/blob/2faacc6a50993038c98789dfa96430a757bdf545/docs/faq.md#operating-systems) to add a dissimilar operating system to compliment Container Linux. Operating Typhoon clusters across colocations and multiple clouds was driven by our own real need and has provided healthy perspective and clear direction. Adding Fedora Atomic is exciting for the same reasons. Fedora Atomic diversifies Typhoon's technology underpinnings, uniting the Container Linux and Fedora Atomic ecosystems to provide a consistent Kubernetes experience across operating systems, clouds, and on-premise.

Get started with the [basics](https://typhoon.psdn.io/architecture/concepts/) or read the OS [comparison](https://typhoon.psdn.io/architecture/operating-systems/). If you're familiar with Terraform, follow the new tutorials for Fedora Atomic on [AWS](https://typhoon.psdn.io/atomic/aws/), [Google Cloud](https://typhoon.psdn.io/atomic/google-cloud/), [DigitalOcean](https://typhoon.psdn.io/atomic/digital-ocean/), and [bare-metal](https://typhoon.psdn.io/atomic/bare-metal/).

*Typhoon is not affiliated with Red Hat or Project Atomic.*

!!! warning
    Heed the warnings. Typhoon for Fedora Atomic is still alpha. Container Linux continues to be the recommended flavor for production clusters. Atomic is not meant to detract from efforts on Container Linux or its derivatives.

!!! tip
    For bare-metal, you may continue to use your v0.7+ [Matchbox](https://github.com/coreos/matchbox) service and `terraform-provider-matchbox` plugin to provision both Container Linux and Fedora Atomic clusters. No changes needed.

[^1]: Using `etcd`, `kubelet`, and `bootkube` as system containers required metadata files be added in [system-containers](https://github.com/poseidon/system-containers)

