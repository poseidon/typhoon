# FAQ

## Terraform?

Typhoon provides a Terraform Module for each supported operating system and platform. Terraform is considered a *format* detail, much like a Linux distro might provide images in the qcow2 or ISO format. It is a mechanism for sharing Typhoon in a way that works for many users.

Formats rise and evolve. Typhoon may choose to adapt the format over time (with lots of forewarning). However, the authors' have built several Kubernetes "distros" before and learned from mistakes - Terraform modules are the right format for now.

## Self-hosted etcd

Typhoon clusters on cloud providers run etcd as "self-hosted" pods, managed by the [etcd-operator](https://github.com/coreos/etcd-operator). By contrast, Typhoon bare-metal runs an etcd peer as a systemd `etcd-member.service` on each controller (i.e. on-host).

In practice, self-hosted etcd has proven to be *ok*, but not ideal. Running the apiserver's etcd atop Kubernetes itself is inherently complex, but works suitably in most cases. It can be opaque to debug if complex edge cases with upstream Kubernetes bugs arise.

!!! note ""
    Typhoon clusters and their defaults power the maintainers' clusters. The edge cases are sufficiently rare that self-hosted etcd is not a pressing issue, but cloud clusters may switch back to on-host etcd in the future.

## Operating Systems

Only Container Linux is supported currently. This just due to operational familiarity, rather than intentional exclusion. It's important that another operating system be added, to reduce the risk of making narrowly-scoped design decisions.

Fedora Cloud will likely be next. 

## Maintainers

Typhoon clusters are Kubernetes configurations the maintainers use in real-world, production clusters.

* Maintainers must personally operate a bare-metal and cloud provider cluster and strive to exercise it in real-world scenarios

We merge features that are along the "blessed path". We minimize options to reduce complexity and matrix size. We remove outdated materials to reduce sprawl. "Skate where the puck is going", but also "wait until the fit is right". No is temporary, yes is forever.
