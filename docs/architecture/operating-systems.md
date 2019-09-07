# Operating Systems

Typhoon supports [Container Linux](https://coreos.com/why/), [Flatcar Linux](https://www.flatcar-linux.org/) and [Fedora CoreOS](https://getfedora.org/coreos/) (preview). These operating systems were chosen because they offer:

* Minimalism and focus on clustered operation
* Automated and atomic operating system upgrades
* Declarative and immutable configuration
* Optimization for containerized applications

Together, they diversify Typhoon to support a range of container technologies.

* Container Linux: Gentoo core, rkt-fly, docker
* Fedora CoreOS: rpm-ostree, podman, moby

## Host Properties

| Property          | Container Linux / Flatcar Linux | Fedora CoreOS |
|-------------------|---------------------------------|---------------|
| Ignition system   | Ignition v2.x spec | Ignition v3.x spec |
| Container Engine  | docker    | docker |
| storage driver    | overlay2  | overlay2 |
| logging driver    | json-file | journald |
| cgroup driver     | cgroupfs (except Flatcar edge) | systemd  |
| Networking        | systemd-networkd | NetworkManager |
| Username          | core      | core |

## Kubernetes Properties

| Property          | Container Linux | Fedora CoreOS |
|-------------------|-----------------|---------------|
| single-master     | all platforms | all platforms |
| multi-master      | all platforms | all platforms |
| control plane     | static pods   | static pods   |
| kubelet image     | upstream hyperkube | upstream hyperkube |
| control plane images | upstream hyperkube | upstream hyperkube |
| on-host etcd      | rkt-fly   | podman |
| on-host kubelet   | rkt-fly   | podman |
| CNI plugins       | calico or flannel | calico or flannel |
| coordinated drain & OS update | [CLUO](https://github.com/coreos/container-linux-update-operator) addon | (planned) |

## Directory Locations

Typhoon conventional directories.

| Kubelet setting   | Host location                  |
|-------------------|--------------------------------|
| cni-conf-dir      | /etc/kubernetes/cni/net.d      |
| pod-manifest-path | /etc/kubernetes/manifests      |
| volume-plugin-dir | /var/lib/kubelet/volumeplugins |

