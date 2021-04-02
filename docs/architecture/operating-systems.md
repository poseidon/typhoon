# Operating Systems

Typhoon supports [Fedora CoreOS](https://getfedora.org/coreos/) and [Flatcar Linux](https://www.flatcar-linux.org/). These operating systems were chosen because they offer:

* Minimalism and focus on clustered operation
* Automated and atomic operating system upgrades
* Declarative and immutable configuration
* Optimization for containerized applications

Together, they diversify Typhoon to support a range of container technologies.

* Fedora CoreOS: rpm-ostree, podman, moby
* Flatcar Linux: Gentoo core, rkt-fly, docker

## Host Properties

| Property          | Flatcar Linux | Fedora CoreOS |
|-------------------|---------------------------------|---------------|
| Kernel            | ~5.4.x | ~5.8.x |
| systemd           | 245 | 245 |
| Ignition system   | Ignition v2.x spec | Ignition v3.x spec |
| Container Engine  | docker 19.3.12  | docker 19.03.11 |
| storage driver    | overlay2 (extfs)  | overlay2 (xfs) |
| logging driver    | json-file | journald |
| cgroup driver     | cgroupfs (except Flatcar edge) | systemd  |
| Networking        | systemd-networkd | NetworkManager |
| Username          | core      | core |

## Kubernetes Properties

| Property          | Flatcar Linux | Fedora CoreOS |
|-------------------|-----------------|---------------|
| single-master     | all platforms | all platforms |
| multi-master      | all platforms | all platforms |
| control plane     | static pods   | static pods   |
| kubelet image     | kubelet [image](https://github.com/poseidon/kubelet) with upstream binary | kubelet [image](https://github.com/poseidon/kubelet) with upstream binary |
| control plane images | upstream images | upstream images |
| on-host etcd      | docker    | podman |
| on-host kubelet   | docker    | podman |
| CNI plugins       | calico, cilium, flannel | calico, cilium, flannel |
| coordinated drain & OS update | [FLUO](https://github.com/kinvolk/flatcar-linux-update-operator) addon | [fleetlock](https://github.com/poseidon/fleetlock) |

## Directory Locations

Typhoon conventional directories.

| Kubelet setting   | Host location                  |
|-------------------|--------------------------------|
| cni-conf-dir      | /etc/cni/net.d                 |
| pod-manifest-path | /etc/kubernetes/manifests      |
| volume-plugin-dir | /var/lib/kubelet/volumeplugins |

