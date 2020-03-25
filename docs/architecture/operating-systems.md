# Operating Systems

Typhoon supports [Fedora CoreOS](https://getfedora.org/coreos/), [Flatcar Linux](https://www.flatcar-linux.org/) and Container Linux (EOL in May 2020). These operating systems were chosen because they offer:

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
| Kernel            | ~4.19.x | ~5.5.x |
| systemd           | 241 | 243 |
| Ignition system   | Ignition v2.x spec | Ignition v3.x spec |
| Container Engine  | docker 18.06.3-ce  | docker 18.09.8 |
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

