# FAQ

## Terraform

Typhoon provides a Terraform Module for each supported operating system and platform. Terraform is considered a *format* detail, much like a Linux distro might provide images in the qcow2 or ISO format. It is a mechanism for sharing Typhoon in a way that works for many users.

Formats rise and evolve. Typhoon may choose to adapt the format over time (with lots of forewarning). However, the authors' have built several Kubernetes "distros" before and learned from mistakes - Terraform modules are the right format for now.

## Operating Systems

Typhoon supports Container Linux and Fedora Atomic 28. These two operating systems were chosen because they offer:

* Minimalism and focus on clustered operation
* Automated and atomic operating system upgrades
* Declarative and immutable configuration
* Optimization for containerized applications

Together, they diversify Typhoon to support a range of container technologies.

* Container Linux: Gentoo core, rkt-fly, docker
* Fedora Atomic: RHEL core, rpm-ostree, system containers (i.e. runc), CRI-O

## Get Help

Ask questions on the IRC #typhoon channel on [freenode.net](http://freenode.net/).

## Security Issues

If you find security issues, please see [security disclosures](/topics/security.md#disclosures).

## Maintainers

Typhoon clusters are Kubernetes clusters the maintainers use in real-world, production clusters.

* Maintainers must personally operate a bare-metal and cloud provider cluster and strive to exercise it in real-world scenarios

We merge features that are along the "blessed path". We minimize options to reduce complexity and matrix size. We remove outdated materials to reduce sprawl. "Skate where the puck is going", but also "wait until the fit is right". No is temporary, yes is forever.
