# Announce <img align="right" src="https://storage.googleapis.com/poseidon/typhoon-logo-small.png">

## Jul 18, 2019

Introducing a preview of Typhoon Kubernetes clusters with Fedora CoreOS!

Fedora recently [announced](https://lists.fedoraproject.org/archives/list/coreos@lists.fedoraproject.org/thread/3HTW5SLUY6X2Y5SFXJSE4BWEDNJ2J5SL/) the first preview release of Fedora CoreOS, aiming to blend the best of CoreOS and Fedora for containerized workloads. To spur testing, Typhoon is sharing preview modules for Kubernetes v1.15 on [AWS](https://typhoon.psdn.io/fedora-coreos/aws/) and [bare-metal](https://typhoon.psdn.io/fedora-coreos/bare-metal/) using the new Fedora CoreOS preview. What better way to test drive than by running Kubernetes?

While Typhoon uses Container Linux (or Flatcar Linux) for stable modules, the project hasn't been a stranger to Fedora ideas, once developing a [Fedora Atomic](https://typhoon.psdn.io/announce/#april-26-2018) variant in 2018. That makes the Fedora CoreOS fushion both exciting and familiar. Typhoon with Fedora CoreOS uses Ignition v3 for provisioning, uses rpm-ostree for layering and updates, tries swapping system containers for podman, and brings SELinux enforcement ([table](https://typhoon.psdn.io/architecture/operating-systems/)). This is an early preview (don't go to prod), but do try it out and help identify and solve issues (getting started links above).

About: For newcomers, Typhoon is a minimal and free (cost and freedom) Kubernetes distribution providing upstream Kubernetes, declarative configuration via Terraform, and support for AWS, Azure, Google Cloud, DigitalOcean, and bare-metal. It is run by former CoreOS engineer [@dghubble](https://twitter.com/dghubble) to power his clusters with freedom [motivations](https://typhoon.psdn.io/#motivation).

## March 27, 2019

Last April, Typhoon [introduced](#april-26-2018) alpha support for creating Kubernetes clusters with Fedora Atomic on AWS, Google Cloud, DigitalOcean, and bare-metal. Fedora Atomic shared many of Container Linux's aims for a container-optimized operating system, introduced novel ideas, and provided technical diversification for an uncertain future. However, Project Atomic efforts were merged into Fedora CoreOS and future Fedora Atomic releases are [not expected](http://www.projectatomic.io/blog/2018/06/welcome-to-fedora-coreos/). *Typhoon modules for Fedora Atomic will not be updated much beyond Kubernetes v1.13*. They may later be removed.

Typhoon for Fedora Atomic fell short of goals to provide a consistent, practical experience across operating systems and platforms. The modules have remained alpha, despite improvements. Features like coordinated OS updates and boot-time declarative customization were not realized. Inelegance of Cloud-Init/kickstart loomed large. With that brief but obligatory summary, I'd like to change gears and celebrate the many positives.

Fedora Atomic showcased [rpm-ostree](https://github.com/projectatomic/rpm-ostree) as a different approach to Container Linux's AB update scheme. It provided a viable route toward [CRI-O](https://github.com/kubernetes-sigs/cri-o) to replace Docker as the container engine. And Fedora Atomic devised [system containers](http://www.projectatomic.io/blog/2016/09/intro-to-system-containers/) as a way to package and run raw OCI images through runc for host-level containers[^2]. Many of these ideas will live on in Fedora CoreOS, which is exciting!

For Typhoon, Fedora Atomic brought fresh ideas and broader perspectives about different container-optimized base operating systems and related tools. Its sad to let go of so much work, but I think its time. Many of the concepts and technologies that were explored will surface again and Typhoon is better positioned as a result.

Thank you Project Atomic team members for your work! - dghubble

[^2]: Container Linux's own primordial rkt-fly shim dates back to the pre-OCI era. In some ways, rkt drove the OCI standards that made newer ideas, like system containers, appealing.

## May 23, 2018

Starting in v1.10.3, Typhoon AWS and bare-metal `container-linux` modules allow picking between the Red Hat [Container Linux](https://coreos.com/os/docs/latest/) (formerly CoreOS Container Linux) and Kinvolk [Flatcar Linux](https://www.flatcar-linux.org/) operating system. Flatcar Linux serves as a drop-in compatible "friendly fork" of Container Linux. Flatcar Linux publishes the same channels and versions as Container Linux and gets provisioned, managed, and operated in an identical way (e.g. login as user "core").

On AWS, pick the Container Linux derivative channel by setting `os_image` to coreos-stable, coreos-beta, coreos-alpha, flatcar-stable, flatcar-beta, or flatcar-alpha.

On bare-metal, pick the Container Linux derivative channel by setting `os_channel` to coreos-stable, coreos-beta, coreos-alpha, flatcar-stable, flatcar-beta, or flatcar-alpha. Set the `os_version` number to PXE boot and install. Variables `container_linux_channel` and `container_linux_version` have been dropped.

Flatcar Linux provides a familar Container Linux experience, with support from Kinvolk as an alternative to Red Hat. Typhoon offers the choice of Container Linux vendor to satisfy differing preferences and to diversify technology underpinnings, while providing a consistent Kubernetes experience across operating systems, clouds, and on-premise.

## April 26, 2018

Introducing Typhoon Kubernetes clusters for Fedora Atomic!

Fedora Atomic is a container-optimized operating system designed for large-scale clustered operation, immutable infrastructure, and atomic operating system upgrades. Its part of [Fedora](https://getfedora.org/en/atomic/download/) and [Project Atomic](http://www.projectatomic.io/docs/introduction/), a Red Hat sponsored project working on rpm-ostree, buildah, skopeo, CRI-O, and the related CentOS/RHEL Atomic.

For newcomers, Typhoon is a free (cost and freedom) Kubernetes distribution providing upstream Kubernetes, declarative configuration via [Terraform](https://www.terraform.io/intro/index.html), and support for AWS, Google Cloud, DigitalOcean, and bare-metal. Typhoon clusters use a [self-hosted](https://github.com/kubernetes-incubator/bootkube) control plane, support [Calico](https://www.projectcalico.org/blog/) and [flannel](https://coreos.com/flannel/docs/latest/) CNI networking, and enable etcd TLS, [RBAC](https://kubernetes.io/docs/admin/authorization/rbac/), and network policy.

Typhoon for Fedora Atomic reflects many of the same principles that created Typhoon for Container Linux. Clusters are declared using plain Terraform configs that can be versioned. In lieu of Ignition, instances are declaratively provisioned with Cloud-Init and kickstart (bare-metal only). TLS assets are generated. Hosts run only a kubelet service, other components are scheduled (i.e. self-hosted). The upstream hyperkube is used directly[^1]. And clusters are kept minimal by offering optional addons for [Ingress](/addons/ingress/), [Prometheus](/addons/prometheus/), and [Grafana](/addons/grafana/). Typhoon compliments and enhances Fedora Atomic as a choice of operating system for Kubernetes.

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
    For bare-metal, you may continue to use your v0.7+ [Matchbox](https://github.com/poseidon/matchbox) service and `terraform-provider-matchbox` plugin to provision both Container Linux and Fedora Atomic clusters. No changes needed.

[^1]: Using `etcd`, `kubelet`, and `bootkube` as system containers required metadata files be added in [system-containers](https://github.com/poseidon/system-containers)

