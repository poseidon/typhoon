# Security

Typhoon aims to be minimal and secure. We're running it ourselves after all.

## Overview

**Kubernetes**

* etcd with peer-to-peer and client-auth TLS
* Generated kubelet TLS certificates and `kubeconfig` (365 days)
* [Role-Based Access Control](https://kubernetes.io/docs/admin/authorization/rbac/) is enabled. Apps must define RBAC policies
* Workloads run on worker nodes only, unless they tolerate the master taint
* Kubernetes [Network Policy](https://kubernetes.io/docs/concepts/services-networking/network-policies/) and Calico [Policy](https://docs.projectcalico.org/latest/reference/calicoctl/resources/policy) support [^1]

[^1]: Requires `networking = "calico"`. Calico is the default on AWS, bare-metal, and Google Cloud. Azure and Digital Ocean are limited to `networking = "flannel"`.

**Hosts**

* Container Linux auto-updates are enabled
* Hosts limit logins to SSH key-based auth (user "core")

**Platform**

* Cloud firewalls limit access to ssh, kube-apiserver, and ingress
* No cluster credentials are stored in Matchbox (used for bare-metal)
* No cluster credentials are stored in Digital Ocean metadata
* Cluster credentials are stored in AWS metadata (for ASGs)
* Cluster credentials are stored in Azure metadata (for scale sets)
* Cluster credentials are stored in Google Cloud metadata (for managed instance groups)
* No account credentials are available to Digital Ocean droplets
* No account credentials are available to AWS EC2 instances (no IAM permissions)
* No account credentials are available to Azure instances (no IAM permissions)
* No account credentials are available to Google Cloud instances (no IAM permissions)

## Precautions

Typhoon limits exposure to many security threats, but it is not a silver bullet. As usual,

* Do not run untrusted images or accept manifests from strangers
* Do not give untrusted users a shell behind your firewall
* Define network policies for your namespaces

## OpenPGP Signing

Typhoon uses upstream container images and binaries. We do not distribute artifacts of our own, except where required for system container images ([etcd](https://quay.io/repository/poseidon/etcd), [kubelet](https://quay.io/repository/poseidon/kubelet), [bootkube](https://quay.io/repository/poseidon/bootkube)) for Fedora Atomic only.

If you find artifacts claiming to be from Typhoon, please send a note.

## Disclosures

If you find security issues, please email dghubble at gmail. If the issue lies in upstream Kubernetes, please inform upstream Kubernetes as well.

