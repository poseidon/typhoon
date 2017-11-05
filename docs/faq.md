# FAQ

## Terraform

Typhoon provides a Terraform Module for each supported operating system and platform. Terraform is considered a *format* detail, much like a Linux distro might provide images in the qcow2 or ISO format. It is a mechanism for sharing Typhoon in a way that works for many users.

Formats rise and evolve. Typhoon may choose to adapt the format over time (with lots of forewarning). However, the authors' have built several Kubernetes "distros" before and learned from mistakes - Terraform modules are the right format for now.

## Self-hosted etcd

AWS clusters run etcd as "self-hosted" pods, managed by the [etcd-operator](https://github.com/coreos/etcd-operator). By contrast, Typhoon bare-metal, Digital Ocean, and Google Cloud run an etcd peer as a systemd `etcd-member.service` on each controller (i.e. on-host).

In practice, self-hosted etcd has proven to be *ok*, but not ideal. Running the apiserver's etcd atop Kubernetes itself is inherently complex, but works in most cases. It can be opaque to debug if complex edge cases with upstream Kubernetes bugs arise.

!!! note ""
    Over time, we plan to deprecate self-hosted etcd and revert to running etcd on-host.

## Operating Systems

Only Container Linux is supported currently. This just due to operational familiarity, rather than intentional exclusion. It's important that another operating system be added, to reduce the risk of making narrowly-scoped design decisions.

Fedora Cloud will likely be next. 

## Get Help

Ask questions on the IRC #typhoon channel on [freenode.net](http://freenode.net/).

## Security Issues

If you find security issues, please see [security disclosures](/topics/security).

## Maintainers

Typhoon clusters are Kubernetes clusters the maintainers use in real-world, production clusters.

* Maintainers must personally operate a bare-metal and cloud provider cluster and strive to exercise it in real-world scenarios

We merge features that are along the "blessed path". We minimize options to reduce complexity and matrix size. We remove outdated materials to reduce sprawl. "Skate where the puck is going", but also "wait until the fit is right". No is temporary, yes is forever.
