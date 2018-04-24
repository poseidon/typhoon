# Operating Systems

Typhoon supports [Container Linux](https://coreos.com/why/) and Fedora [Atomic](https://www.projectatomic.io/) 27. These two operating systems were chosen because they offer:

* Minimalism and focus on clustered operation
* Automated and atomic operating system upgrades
* Declarative and immutable configuration
* Optimization for containerized applications

Together, they diversify Typhoon to support a range of container technologies.

* Container Linux: Gentoo core, rkt-fly, docker
* Fedora Atomic: RHEL core, rpm-ostree, system containers (i.e. runc), CRI-O

## Kubernetes

| Property          | Container Linux | Fedora Atomic |
|-------------------|-----------------|---------------|
| control plane     | self-hosted | self-hosted |
| kubelet image     | upstream hyperkube | upstream hyperkube in system container |
| controller images | upstream hyperkube | upstream hyperkube |
| on-host etcd      | rkt-fly   | system container (runc) |
| on-host kubelet   | rkt-fly   | system container (runc) |
| host spec (bare-metal) | Container Linux Config | kickstart, cloud-init | 
| host spec (cloud)      | Container Linux Config | cloud-init |
| CNI plugins       | calico or flannel | calico or flannel |
| container runtime | docker    | docker (CRIO soon) |
| cgroup driver     | cgroupfs  | systemd  |
| logging driver    | json-file | journald |
| storage driver    | overlay2  | overlay2 |

## Locations

Typhoon standard locations.

| Kubelet setting   | Host location                  |
|-------------------|--------------------------------|
| cni-conf-dir      | /etc/kubernetes/cni/net.d      |
| pod-manifest-path | /etc/kubernetes/manifests      |
| volume-plugin-dir | /var/lib/kubelet/volumeplugins |

## Kubelet Mounts

### Container Linux

| Mount location    | Host location     | Options |
|-------------------|-------------------|---------|
| /etc/kubernetes   | /etc/kubernetes   | ro |
| /etc/ssl/certs    | /etc/ssl/certs    | ro |
| /usr/share/ca-certificates | /usr/share/ca-certificates | ro |
| /var/lib/kubelet  | /var/lib/kubelet  | recursive |
| /var/lib/docker   | /var/lib/docker   | |
| /var/lib/cni      | /var/lib/cni      | |
| /var/lib/calico   | /var/lib/calico   | |
| /var/log          | /var/log          | |
| /etc/os-release   | /usr/lib/os-release | ro |
| /run              | /run |            |
| /lib/modules      | /lib/modules | ro |
| /etc/resolv.conf  | /etc/resolv.conf  | |
| /opt/cni/bin      | /opt/cni/bin      | |


### Fedora Atomic

| Mount location     | Host location    | Options |
|--------------------|------------------|---------|
| /rootfs            | /                | ro |
| /etc/kubernetes    | /etc/kubernetes  | ro |
| /etc/ssl/certs     | /etc/ssl/certs   | ro |
| /etc/pki/tls/certs | /usr/share/ca-certificates | ro |
| /var/lib           | /var/lib         | |
| /var/lib/kubelet   | /var/lib/kubelet | recursive |
| /var/log           | /var/log         | ro |
| /etc/os-release    | /etc/os-release  | ro |
| /var/run/secrets   | /var/run/secrets | |
| /run               | /run             | |
| /lib/modules       | /lib/modules     | ro |
| /etc/hosts         | /etc/hosts       | ro |
| /etc/resolv.conf   | /etc/resolv.conf | ro |
| /opt/cni/bin       | /opt/cni/bin     | |

