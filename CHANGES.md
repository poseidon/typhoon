# Typhoon

Notable changes between versions.

## Latest

* Kubernetes [v1.20.5](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.20.md#v1205)
* Update etcd from v3.4.14 to [v3.4.15](https://github.com/etcd-io/etcd/releases/tag/v3.4.15)
* Update Cilium from v1.9.4 to [v1.9.5](https://github.com/cilium/cilium/releases/tag/v1.9.5)
* Update Calico from v3.17.3 to [v3.18.1](https://github.com/projectcalico/calico/releases/tag/v3.18.1)
* Update CoreDNS from v1.7.0 to [v1.8.0](https://coredns.io/2020/10/22/coredns-1.8.0-release/)
* Mark bootstrap token as sensitive in Terraform plans ([#949](https://github.com/poseidon/typhoon/pull/949))

### Flatcar Linux

#### AWS

* Remove `os_image` option `flatcar-edge` ([#943](https://github.com/poseidon/typhoon/pull/943))

#### Azure

* Remove `os_image` option `flatcar-edge` ([#943](https://github.com/poseidon/typhoon/pull/943))

#### Bare-Metal

* Remove `os_channel` option `flatcar-edge` ([#943](https://github.com/poseidon/typhoon/pull/943))

### Addons

* Update Prometheus from v2.25.0 to [v2.25.2](https://github.com/prometheus/prometheus/releases/tag/v2.25.2)
* Update kube-state-metrics from v2.0.0-alpha.3 to [v2.0.0-rc.0](https://github.com/kubernetes/kube-state-metrics/releases/tag/v2.0.0-rc.0)
  * Switch image from `quay.io` to `k8s.gcr.io` ([#946](https://github.com/poseidon/typhoon/pull/946))
* Update node-exporter from v1.1.1 to [v1.1.2](https://github.com/prometheus/node_exporter/releases/tag/v1.1.2)
* Update Grafana from v7.4.2 to [v7.4.5](https://github.com/grafana/grafana/releases/tag/v7.4.5)

## v1.20.4

* Kubernetes [v1.20.4](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.20.md#v1204)
* Update Cilium from v1.9.1 to [v1.9.4](https://github.com/cilium/cilium/releases/tag/v1.9.4)
* Update Calico from v3.17.1 to [v3.17.3](https://github.com/projectcalico/calico/releases/tag/v3.17.3)
* Update flannel-cni from v0.4.1 to [v0.4.2](https://github.com/poseidon/flannel-cni/releases/tag/v0.4.2)

### Addons

* Update nginx-ingress from v0.43.0 to [v0.44.0](https://github.com/kubernetes/ingress-nginx/releases/tag/controller-v0.44.0)
* Update Prometheus from v2.24.0 to [v2.25.0](https://github.com/prometheus/prometheus/releases/tag/v2.25.0)
  * Update node-exporter from v1.0.1 to [v1.1.1](https://github.com/prometheus/node_exporter/releases/tag/v1.1.1)
* Update Grafana from v7.3.7 to [v7.4.2](https://github.com/grafana/grafana/releases/tag/v7.4.2)

## v1.20.2

* Kubernetes [v1.20.2](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.20.md#v1202)
* Support Terraform v0.13.x and v0.14.4+ ([#924](https://github.com/poseidon/typhoon/pull/923))

### Addons

* Update nginx-ingress from v0.41.2 to [v0.43.0](https://github.com/kubernetes/ingress-nginx/releases/tag/controller-v0.43.0)
* Update Prometheus from v2.23.0 to [v2.24.0](https://github.com/prometheus/prometheus/releases/tag/v2.24.0)
* Update Grafana from v7.3.6 to [v7.3.7](https://github.com/grafana/grafana/releases/tag/v7.3.7)

## v1.20.1

* Kubernetes [v1.20.1](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.20.md#v1201)

### Fedora CoreOS

* Fedora CoreOS 33 has stronger crypto defaults ([**notice**](https://docs.fedoraproject.org/en-US/fedora-coreos/faq/#_why_does_ssh_stop_working_after_upgrading_to_fedora_33), [#915](https://github.com/poseidon/typhoon/issues/915))
  * Use a non-RSA SSH key or add the workaround provided in upstream [Fedora docs](https://docs.fedoraproject.org/en-US/fedora-coreos/faq/#_why_does_ssh_stop_working_after_upgrading_to_fedora_33) as a [snippet](https://typhoon.psdn.io/advanced/customization/#fedora-coreos) (**action required**)

### Addons

* Update Grafana from v7.3.5 to [v7.3.6](https://github.com/grafana/grafana/releases/tag/v7.3.6)

## v1.20.0

* Kubernetes [v1.20.0](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.20.md#v1200)
* Add input variable validations ([#880](https://github.com/poseidon/typhoon/pull/880))
  * Require Terraform v0.13+ ([migration guide](https://typhoon.psdn.io/topics/maintenance/#terraform-versions))
* Set output sensitive to suppress console display for some cases ([#885](https://github.com/poseidon/typhoon/pull/885))
* Add service account token [volume projection](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#service-account-token-volume-projection) ([#897](https://github.com/poseidon/typhoon/pull/897))
* Scope kube-scheduler and kube-controller-manager permissions ([#898](https://github.com/poseidon/typhoon/pull/898))
* Update etcd from v3.4.12 to [v3.4.14](https://github.com/etcd-io/etcd/releases/tag/v3.4.14)
* Update Calico from v3.16.5 to v3.17.1 ([#890](https://github.com/poseidon/typhoon/pull/890))
  * Enable Calico MTU auto-detection
  * Remove [workaround](https://github.com/poseidon/typhoon/pull/724) to Calico cni-plugin [issue](https://github.com/projectcalico/cni-plugin/issues/874)
* Update Cilium from v1.9.0 to [v1.9.1](https://github.com/cilium/cilium/releases/tag/v1.9.1)
* Relax `terraform-provider-ct` version constraint to v0.6+ ([#893](https://github.com/poseidon/typhoon/pull/893))
  * Allow upgrading `terraform-provider-ct` to v0.7.x ([warn](https://typhoon.psdn.io/topics/maintenance/#upgrade-terraform-provider-ct))

### AWS

* Enable Network Load Balancer (NLB) dualstack ([#883](https://github.com/poseidon/typhoon/pull/883))
  * NLB subnets assigned both IPv4 and IPv6 addresses
  * NLB DNS name has both A and AAAA records
  * NLB to target node traffic is IPv4 (no change)

### Bare-Metal

* Remove iSCSI `/etc/iscsi` and `iscsadm` mounts from Kubelet ([#912](https://github.com/poseidon/typhoon/pull/912))

### Fedora CoreOS

#### AWS

* Fix AMI query for which could fail in some regions ([#887](https://github.com/poseidon/typhoon/pull/887))

#### Bare-Metal

* Promote Fedora CoreOS to stable
* Use initramfs and rootfs images as initrd's ([#889](https://github.com/poseidon/typhoon/pull/889))
  * Requires Fedora CoreOS version with rootfs images (e.g. 32.20200923.3.0+)

### Addons

* Update Prometheus from v2.22.2 to [v2.23.0](https://github.com/prometheus/prometheus/releases/tag/v2.23.0)
* Update kube-state-metrics from v2.0.0-alpha.2 to [v2.0.0-alpha.3](https://github.com/kubernetes/kube-state-metrics/releases/tag/v2.0.0-alpha.3)
* Update Grafana from v7.3.2 to [v7.3.5](https://github.com/grafana/grafana/releases/tag/v7.3.5)

## v1.19.4

* Kubernetes [v1.19.4](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.19.md#v1194)
* Update Cilium from v1.8.4 to [v1.9.0](https://github.com/cilium/cilium/releases/tag/v1.9.0)
* Update Calico from v3.16.3 to [v3.16.5](https://github.com/projectcalico/calico/releases/tag/v3.16.5)
* Remove `asset_dir` variable (defaulted off in [v1.17.0](https://github.com/poseidon/typhoon/pull/595), deprecated in [v1.18.0](https://github.com/poseidon/typhoon/pull/678))

### Fedora CoreOS

* Improve `etcd-member.service` systemd unit ([#868](https://github.com/poseidon/typhoon/pull/868))
  * Allow a snippet with a systemd dropin to set an alternate image (e.g. mirror)
* Fix local node delete oneshot on node shutdown ([#856](https://github.com/poseidon/typhoon/pull/855))

#### AWS

* Add experimental Fedora CoreOS arm64 support ([docs](https://typhoon.psdn.io/advanced/arm64/), [#875](https://github.com/poseidon/typhoon/pull/875))
  * Allow arm64 full-cluster or mixed/hybrid cluster with worker pools
  * Add `arch` variable to cluster module
  * Add `daemonset_tolerations` variable to cluster module
  * Add `node_taints` variable to workers module
  * Requires flannel CNI provider and use of experimental AMI (see docs)

### Flatcar Linux

* Rename `container-linux` modules to `flatcar-linux` ([#858](https://github.com/poseidon/typhoon/issues/858)) (**action required**)
* Change on-host system containers from rkt to docker
  * Change `etcd-member.service` container runnner from rkt to docker ([#867](https://github.com/poseidon/typhoon/pull/867))
  * Change `kubelet.service` container runner from rkt-fly to docker ([#855](https://github.com/poseidon/typhoon/pull/855))
  * Change `bootstrap.service` container runner from rkt to docker ([#873](https://github.com/poseidon/typhoon/pull/873))
  * Change `delete-node.service` to use docker and an inline ExecStart ([#855](https://github.com/poseidon/typhoon/pull/855))
* Fix local node delete oneshot on node shutdown ([#855](https://github.com/poseidon/typhoon/pull/855))
* Remove CoreOS Container Linux Matchbox profiles ([#859](https://github.com/poseidon/typhoon/pull/858))

### Addons

* Update nginx-ingress from v0.40.2 to [v0.41.2](https://github.com/kubernetes/ingress-nginx/releases/tag/controller-v0.41.2)
* Update Prometheus from v2.22.0 to [v2.22.1](https://github.com/prometheus/prometheus/releases/tag/v2.22.1)
* Update kube-state-metrics from v2.0.0-alpha.1 to [v2.0.0-alpha.2](https://github.com/kubernetes/kube-state-metrics/releases/tag/v2.0.0-alpha.2)
* Update Grafana from v7.2.1 to [v7.3.2](https://github.com/grafana/grafana/releases/tag/v7.3.2)

## v1.19.3

* Kubernetes [v1.19.3](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.19.md#v1193)
* Update Cilium from v1.8.3 to [v1.8.4](https://github.com/cilium/cilium/releases/tag/v1.8.4)
* Update Calico from v1.15.3 to [v1.16.3](https://github.com/projectcalico/calico/releases/tag/v3.16.3) ([#851](https://github.com/poseidon/typhoon/pull/851))
* Update flannel from v0.13.0-rc2 to v0.13.0 ([#219](https://github.com/poseidon/terraform-render-bootstrap/pull/219))

### Flatcar Linux

* Remove references to CoreOS Container Linux ([#839](https://github.com/poseidon/typhoon/pull/839))
  * Fix error querying for coreos AMI on AWS ([#838](https://github.com/poseidon/typhoon/issues/838))

### Addons

* Update nginx-ingress from v0.35.0 to [v0.40.2](https://github.com/kubernetes/ingress-nginx/releases/tag/controller-v0.40.2)
* Update Grafana from v7.1.5 to [v7.2.1](https://github.com/grafana/grafana/releases/tag/v7.2.1)
* Update Prometheus from v2.21.0 to [v2.22.0](https://github.com/prometheus/prometheus/releases/tag/v2.22.0)
  * Update kube-state-metrics from v1.9.7 to [v2.0.0-alpha.1](https://github.com/kubernetes/kube-state-metrics/releases/tag/v2.0.0-alpha.1)

## v1.19.2

* Kubernetes [v1.19.2](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.19.md#v1192)
* Update flannel from v0.12.0 to v0.13.0-rc2 ([#216](https://github.com/poseidon/terraform-render-bootstrap/pull/216))
  * Update flannel-cni from v0.4.0 to v0.4.1
  * Update CNI plugins from v0.8.6 to v0.8.7

### Addons

* Refresh Prometheus rules/alerts and Grafana dashboards ([#831](https://github.com/poseidon/typhoon/pull/831))
* Reduce apiserver metrics cardinality for non-core APIs ([#830](https://github.com/poseidon/typhoon/pull/830))

## v1.19.1

* Kubernetes [v1.19.1](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.19.md#v1191)
  * Change control plane seccomp annotations to GA `seccompProfile` ([#822](https://github.com/poseidon/typhoon/pull/822))
* Update Cilium from v1.8.2 to [v1.8.3](https://github.com/cilium/cilium/releases/tag/v1.8.3)
  * Promote Cilium from experimental to general availability ([#827](https://github.com/poseidon/typhoon/pull/827))
* Update Calico from v1.15.2 to [v1.15.3](https://github.com/projectcalico/calico/releases/tag/v3.15.3)

### Fedora CoreOS

* Update Fedora CoreOS Config version from v1.0.0 to v1.1.0
  * Require any [snippets](https://typhoon.psdn.io/advanced/customization/#hosts) customizations to update to v1.1.0

### Addons

* Update IngressClass resources to `networking.k8s.io/v1` ([#824](https://github.com/poseidon/typhoon/pull/824))
* Update Prometheus from v2.20.0 to [v2.21.0](https://github.com/prometheus/prometheus/releases/tag/v2.21.0)
  * Remove Kubernetes node name labelmap `relabel_config` from etcd, Kubelet, and CAdvisor scrape config ([#828](https://github.com/poseidon/typhoon/pull/828))

## v1.19.0

* Kubernetes [v1.19.0](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.19.md#v1190)
* Update etcd from v3.4.10 to [v3.4.12](https://github.com/etcd-io/etcd/releases/tag/v3.4.12)
* Update Calico from v3.15.1 to [v3.15.2](https://docs.projectcalico.org/v3.15/release-notes/)

### Fedora CoreOS

* Fix race condition during bootstrap of multi-controller clusters ([#808](https://github.com/poseidon/typhoon/pull/808))
  * Fix SELinux label of bootstrap-secrets on non-bootstrap controllers

### Addons

* Introduce [fleetlock](https://github.com/poseidon/fleetlock) for Fedora CoreOS reboot coordination ([#814](https://github.com/poseidon/typhoon/pull/814))
* Update nginx-ingress from v0.34.1 to [v0.35.0](https://github.com/kubernetes/ingress-nginx/releases/tag/controller-v0.35.0)
  * Repository changed to `k8s.gcr.io/ingress-nginx/controller`
* Update Grafana from v7.1.3 to [v7.1.5](https://github.com/grafana/grafana/releases/tag/v7.1.5)

## v1.18.8

* Kubernetes [v1.18.8](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.18.md#v1188)
* Migrate from Terraform v0.12.x to v0.13.x ([#804](https://github.com/poseidon/typhoon/pull/804)) (**action required**)
  * Recommend Terraform v0.13.x ([migration guide](https://typhoon.psdn.io/topics/maintenance/#terraform-versions))
  * Support automatic install of poseidon's provider plugins ([poseidon/ct](https://registry.terraform.io/providers/poseidon/ct/latest), [poseidon/matchbox](https://registry.terraform.io/providers/poseidon/matchbox/latest))
  * Require Terraform v0.12.26+ (migration compatibility)
  * Require `terraform-provider-ct` v0.6.1
  * Require `terraform-provider-matchbox` v0.4.1
* Update etcd from v3.4.9 to [v3.4.10](https://github.com/etcd-io/etcd/releases/tag/v3.4.10)
* Update CoreDNS from v1.6.7 to [v1.7.0](https://coredns.io/2020/06/15/coredns-1.7.0-release/)
* Update Cilium from v1.8.1 to [v1.8.2](https://github.com/cilium/cilium/releases/tag/v1.8.2)
* Update [coreos/flannel-cni](https://github.com/coreos/flannel-cni) to [poseidon/flannel-cni](https://github.com/poseidon/flannel-cni) ([#798](https://github.com/poseidon/typhoon/pull/798))
  * Update CNI plugins and fix CVEs with Flannel CNI (non-default)
  * Transition to a poseidon maintained container image

### AWS

* Allow `terraform-provider-aws` v3.0+ ([#803](https://github.com/poseidon/typhoon/pull/803))
  * Recommend updating `terraform-provider-aws` to v3.0+
  * Continue to allow v2.23+, no v3.x specific features are used

### DigitalOcean

* Require `terraform-provider-digitalocean` v1.21+ for Terraform v0.13.x (unenforced)
* Require `terraform-provider-digitalocean` v1.20+ for Terraform v0.12.x

### Fedora CoreOS

* Fix support for Flannel with Fedora CoreOS ([#795](https://github.com/poseidon/typhoon/pull/795))
  * Configure `flannel.1` link to select its own MAC address to solve flannel
  pod-to-pod traffic drops starting with default link changes in Fedora CoreOS
  32.20200629.3.0 ([details](https://github.com/coreos/fedora-coreos-tracker/issues/574#issuecomment-665487296))

#### Addons

* Update Prometheus from v2.19.2 to [v2.20.0](https://github.com/prometheus/prometheus/releases/tag/v2.20.0)
* Update Grafana from v7.0.6 to [v7.1.3](https://github.com/grafana/grafana/releases/tag/v7.1.3)

## v1.18.6

* Kubernetes [v1.18.6](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.18.md#v1186)
* Update Calico from v3.15.0 to [v3.15.1](https://docs.projectcalico.org/v3.15/release-notes/)
* Update Cilium from v1.8.0 to [v1.8.1](https://github.com/cilium/cilium/releases/tag/v1.8.1)

#### Addons

* Update nginx-ingress from v0.33.0 to [v0.34.1](https://github.com/kubernetes/ingress-nginx/releases/tag/nginx-0.34.1)
  * [ingress-nginx](https://github.com/kubernetes/ingress-nginx/releases/tag/controller-v0.34.0) will publish images only to gcr.io
* Update Prometheus from v2.19.1 to [v2.19.2](https://github.com/prometheus/prometheus/releases/tag/v2.19.2)
* Update Grafana from v7.0.4 to [v7.0.6](https://github.com/grafana/grafana/releases/tag/v7.0.6)

## v1.18.5

* Kubernetes [v1.18.5](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.18.md#v1185)
* Add Cilium v1.8.0 as a (experimental) CNI provider option ([#760](https://github.com/poseidon/typhoon/pull/760))
  * Set `networking` to "cilium" to enable
* Update Calico from v3.14.1 to [v3.15.0](https://docs.projectcalico.org/v3.15/release-notes/)

#### DigitalOcean

* Isolate each cluster in an independent DigitalOcean VPC ([#776](https://github.com/poseidon/typhoon/pull/776))
  * Create droplets in a VPC per cluster (matches Typhoon AWS, Azure, and GCP)
  * Require `terraform-provider-digitalocean` v1.16.0+ (action required)
  * Output `vpc_id` for use with an attached DigitalOcean [loadbalancer](https://github.com/poseidon/typhoon/blob/v1.18.5/docs/architecture/digitalocean.md#custom-load-balancer)

### Fedora CoreOS

#### Google Cloud

* Promote Fedora CoreOS to stable
* Remove `os_image` variable deprecated in v1.18.3 ([#777](https://github.com/poseidon/typhoon/pull/777))
  * Use `os_stream` to select a Fedora CoreOS image stream

### Flatcar Linux

#### Azure

* Allow using Flatcar Linux Edge by setting `os_image` to "flatcar-edge" ([#778](https://github.com/poseidon/typhoon/pull/778))

#### Addons

* Update Prometheus from v2.19.0 to [v2.19.1](https://github.com/prometheus/prometheus/releases/tag/v2.19.1)
* Update Grafana from v7.0.3 to [v7.0.4](https://github.com/grafana/grafana/releases/tag/v7.0.4)

## v1.18.4

* Kubernetes [v1.18.4](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.18.md#v1184)
* Update Kubelet image publishing ([#749](https://github.com/poseidon/typhoon/pull/749))
  * Build Kubelet images internally and publish to Quay and Dockerhub
    * [quay.io/poseidon/kubelet](https://quay.io/repository/poseidon/kubelet) (official)
    * [docker.io/psdn/kubelet](https://hub.docker.com/r/psdn/kubelet) (fallback)
  * Continue offering automated image builds with an alternate tag strategy (see [docs](https://typhoon.psdn.io/topics/security/#container-images))
  * [Document](https://typhoon.psdn.io/advanced/customization/#kubelet) use of alternate Kubelet images during registry incidents
* Update Calico from v3.14.0 to [v3.14.1](https://docs.projectcalico.org/v3.14/release-notes/)
  * Fix [CVE-2020-13597](https://github.com/kubernetes/kubernetes/issues/91507)
* Rename controller NoSchedule taint from `node-role.kubernetes.io/master` to `node-role.kubernetes.io/controller` ([#764](https://github.com/poseidon/typhoon/pull/764))
  * Tolerate the new taint name for workloads that may run on controller nodes
* Remove node label `node.kubernetes.io/master` from controller nodes ([#764](https://github.com/poseidon/typhoon/pull/764))
  * Use `node.kubernetes.io/controller` (present since v1.9.5, [#160](https://github.com/poseidon/typhoon/pull/160)) to node select controllers
* Remove unused Kubelet `-lock-file` and `-exit-on-lock-contention` ([#758](https://github.com/poseidon/typhoon/pull/758))

### Fedora CoreOS

#### Azure

* Use `strict` Fedora CoreOS Config (FCC) snippet parsing ([#755](https://github.com/poseidon/typhoon/pull/755))
* Reduce Calico vxlan interface MTU to maintain performance ([#767](https://github.com/poseidon/typhoon/pull/766))

#### AWS

* Fix Kubelet service race with hostname update ([#766](https://github.com/poseidon/typhoon/pull/766))
  * Wait for a hostname to avoid Kubelet trying to register as `localhost`

### Flatcar Linux

* Use `strict` Container Linux Config (CLC) snippet parsing ([#755](https://github.com/poseidon/typhoon/pull/755))
  * Require `terraform-provider-ct` v0.4+, recommend v0.5+ (**action required**)

### Addons

* Update nginx-ingress from v0.32.0 to [v0.33.0](https://github.com/kubernetes/ingress-nginx/releases/tag/nginx-0.33.0)
* Update Prometheus from v2.18.1 to [v2.19.0](https://github.com/prometheus/prometheus/releases/tag/v2.19.0)
* Update node-exporter from v1.0.0-rc.1 to [v1.0.1](https://github.com/prometheus/node_exporter/releases/tag/v1.0.1)
* Update kube-state-metrics from v1.9.6 to v1.9.7
* Update Grafana from v7.0.0 to v7.0.3

## v1.18.3

* Kubernetes [v1.18.3](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.18.md#v1183)
* Use Kubelet [TLS bootstrap](https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet-tls-bootstrapping/) with bootstrap token authentication ([#713](https://github.com/poseidon/typhoon/pull/713))
  * Enable Node [Authorization](https://kubernetes.io/docs/reference/access-authn-authz/node/) and [NodeRestriction](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#noderestriction) to reduce authorization scope
  * Renew Kubelet certificates every 72 hours
* Update etcd from v3.4.7 to [v3.4.9](https://github.com/etcd-io/etcd/releases/tag/v3.4.9)
* Update Calico from v3.13.1 to [v3.14.0](https://docs.projectcalico.org/v3.14/release-notes/)
* Add CoreDNS node affinity preference for controller nodes ([#188](https://github.com/poseidon/terraform-render-bootstrap/pull/188))
* Deprecate CoreOS Container Linux support (no OS [updates](https://coreos.com/os/eol/) after May 2020)
  * Use a `fedora-coreos` module for Fedora CoreOS
  * Use a `container-linux` module for Flatcar Linux

### AWS

* Fix Terraform plan error when `controller_count` exceeds AWS zones (e.g. 5 controllers) ([#714](https://github.com/poseidon/typhoon/pull/714))
  * Regressed in v1.17.1 ([#605](https://github.com/poseidon/typhoon/pull/605))

### Azure

* Update Azure subnets to set `address_prefixes` list ([#730](https://github.com/poseidon/typhoon/pull/730))
  * Fix warning that `address_prefix` is deprecated
  * Require `terraform-provider-azurerm` v2.8.0+ (action required)

### DigitalOcean

* Promote DigitalOcean to beta on both Fedora CoreOS and Flatcar Linux

### Fedora CoreOS

* Fix Calico `install-cni` crashloop on Pod restarts ([#724](https://github.com/poseidon/typhoon/pull/724))
  * SELinux enforcement requires consistent file context MCS level
  * Restarting a node resolved the issue as a previous workaround

#### AWS

* Support Fedora CoreOS [image streams](https://docs.fedoraproject.org/en-US/fedora-coreos/update-streams/) ([#727](https://github.com/poseidon/typhoon/pull/727))
  * Add `os_stream` variable to set the stream to `stable` (default), `testing`, or `next`
  * Remove unused `os_image` variable

#### Google

* Support Fedora CoreOS [image streams](https://docs.fedoraproject.org/en-US/fedora-coreos/update-streams/) ([#723](https://github.com/poseidon/typhoon/pull/723))
  * Add `os_stream` variable to set the stream to `stable` (default), `testing`, or `next`
  * Deprecate `os_image` variable. Manual image uploads are no longer needed

### Flatcar Linux

#### Azure

* Use the Flatcar Linux Azure Marketplace image
  * Restore [#664](https://github.com/poseidon/typhoon/pull/664) (reverted in [#707](https://github.com/poseidon/typhoon/pull/707)) but use Flatcar Linux new free offer (not byol)
* Change `os_image` to use a `flatcar-stable` default

#### Google

* Promote Flatcar Linux to beta

### Addons

* Update nginx-ingress from v0.30.0 to [v0.32.0](https://github.com/kubernetes/ingress-nginx/releases/tag/nginx-0.32.0)
  * Add support for [IngressClass](https://kubernetes.io/docs/concepts/services-networking/ingress/#ingress-class)
* Update Prometheus from v2.17.1 to v2.18.1
  * Update kube-state-metrics from v1.9.5 to [v1.9.6](https://github.com/kubernetes/kube-state-metrics/releases/tag/v1.9.6)
  * Update node-exporter from v1.0.0-rc.0 to [v1.0.0-rc.1](https://github.com/prometheus/node_exporter/releases/tag/v1.0.0-rc.1)
* Update Grafana from v6.7.2 to [v7.0.0](https://grafana.com/docs/grafana/latest/guides/whats-new-in-v7-0/)

## v1.18.2

* Kubernetes [v1.18.2](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.18.md#v1182)
* Choose Fedora CoreOS or Flatcar Linux (**action required**)
  * Use a `fedora-coreos` module for Fedora CoreOS
  * Use a `container-linux` module for Flatcar Linux
* Change Container Linux modules' defaults from CoreOS Container Linux to [Flatcar Container Linux](https://typhoon.psdn.io/architecture/operating-systems/) ([#702](https://github.com/poseidon/typhoon/pull/702))
  * CoreOS Container Linux [won't receive updates](https://coreos.com/os/eol/) after May 2020

### Fedora CoreOS

* Fix bootstrap race condition from SELinux unshared content label ([#708](https://github.com/poseidon/typhoon/pull/708))

#### Azure

* Add support for Fedora CoreOS ([#704](https://github.com/poseidon/typhoon/pull/704))

#### DigitalOcean

* Fix race condition creating firewall allow rules ([#709](https://github.com/poseidon/typhoon/pull/709))

### Flatcar Linux

#### AWS

* Change `os_image` default from `coreos-stable` to `flatcar-stable` ([#702](https://github.com/poseidon/typhoon/pull/702))

#### Azure

* Change `os_image` to be required. Recommend uploading a Flatcar Linux image (**action required**) ([#702](https://github.com/poseidon/typhoon/pull/702))
* Disable Flatcar Linux Azure Marketplace image [support](https://github.com/poseidon/typhoon/pull/664) (**breaking**, [#707](https://github.com/poseidon/typhoon/pull/707))
  * Revert to manual uploading until marketplace issue is closed ([#703](https://github.com/poseidon/typhoon/issues/703))

#### Bare-Metal

* Recommend changing [os_channel](https://typhoon.psdn.io/cl/bare-metal/#required) from `coreos-stable` to `flatcar-stable`

#### Google

* Change `os_image` to be required. Recommend uploading a Flatcar Linux image (**action required**) ([#702](https://github.com/poseidon/typhoon/pull/702))

#### DigitalOcean

* Change `os_image` to be required. Recommend uploading a Flatcar Linux image (**action required**) ([#702](https://github.com/poseidon/typhoon/pull/702))
* Fix race condition creating firewall allow rules ([#709](https://github.com/poseidon/typhoon/pull/709))

## v1.18.1

* Kubernetes [v1.18.1](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.18.md#v1181)
* Choose Fedora CoreOS or Flatcar Linux (**action recommended**)
  * Use a `fedora-coreos` module for Fedora CoreOS
  * Use a `container-linux` module with OS set to Flatcar Linux
* Update etcd from v3.4.5 to [v3.4.7](https://github.com/etcd-io/etcd/releases/tag/v3.4.7)
* Change `kube-proxy` and `calico` or `flannel` to tolerate specific taints ([#682](https://github.com/poseidon/typhoon/pull/682))
  * Tolerate master and not-ready taints, rather than tolerating all taints
* Update flannel from v0.11.0 to v0.12.0 ([#690](https://github.com/poseidon/typhoon/pull/690))
* Fix bootstrap when `networking` mode `flannel` (non-default) is chosen ([#689](https://github.com/poseidon/typhoon/pull/689))
  * Regressed in v1.18.0 changes for Calico ([#675](https://github.com/poseidon/typhoon/pull/675))
* Rename Container Linux `controller_clc_snippets` to `controller_snippets` for consistency ([#688](https://github.com/poseidon/typhoon/pull/688))
* Rename Container Linux `worker_clc_snippets` to `worker_snippets` for consistency
* Rename Container Linux `clc_snippets` (bare-metal) to `snippets` for consistency
* Drop support for [gitRepo](https://kubernetes.io/docs/concepts/storage/volumes/#gitrepo) volumes ([kubelet#3](https://github.com/poseidon/kubelet/pull/3))

#### Azure

* Fix Azure worker UDP outbound connections ([#691](https://github.com/poseidon/typhoon/pull/691))
  * Fix Azure worker clock sync timeouts

#### DigitalOcean

* Add support for Fedora CoreOS ([#699](https://github.com/poseidon/typhoon/pull/699))

#### Addons

* Refresh Prometheus rules/alerts and Grafana dashboards ([#692](https://github.com/poseidon/typhoon/pull/692))
* Update Grafana from v6.7.1 to v6.7.2

## v1.18.0

* Kubernetes [v1.18.0](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.18.md#v1180)
* Update etcd from v3.4.4 to [v3.4.5](https://github.com/etcd-io/etcd/releases/tag/v3.4.5)
* Switch from upstream hyperkube image to individual images ([#669](https://github.com/poseidon/typhoon/pull/669))
  * Use upstream k8s.gcr.io `kube-apiserver`, `kube-controller-manager`, `kube-scheduler`, and `kube-proxy` container images
  * Use [poseidon/kubelet](https://github.com/poseidon/kubelet) to package the upstream Kubelet binary and dependencies as a container image (checksummed, automated build)
  * Add [quay.io/poseidon/kubelet](https://quay.io/repository/poseidon/kubelet) as a Typhoon distributed artifact in the security policy
  * Update base images from debian 9 to debian 10
  * Background: Kubernetes will [stop releasing](https://github.com/kubernetes/kubernetes/pull/88676) the hyperkube container image and provide the Kubelet as a binary for packaging
* Choose Fedora CoreOS or Flatcar Linux (**action recommended**)
  * Use a `fedora-coreos` module for Fedora CoreOS
  * Use a `container-linux` module with OS set for Flatcar Linux (varies, see docs)
  * CoreOS Container Linux [won't receive updates](https://coreos.com/os/eol/) after May 2020
* Add support for Fedora CoreOS snippets (`terraform-provider-ct` v0.5+) ([#686](https://github.com/poseidon/typhoon/pull/686))
* Recommend updating `terraform-provider-ct` plugin from v0.4.0 to [v0.5.0](https://github.com/poseidon/terraform-provider-ct/releases/tag/v0.5.0)
* Set Fedora CoreOS log driver back to the default `journald` ([#681](https://github.com/poseidon/typhoon/pull/681))
* Deprecate `asset_dir` variable and remove docs ([#678](https://github.com/poseidon/typhoon/pull/678))
* Deprecate support for [gitRepo](https://kubernetes.io/docs/concepts/storage/volumes/#gitrepo) volumes. A future release will drop support.

#### AWS

* Fix Fedora CoreOS AMI to filter for stable images ([#685](https://github.com/poseidon/typhoon/pull/685))
  * Latest Fedora CoreOS `testing` or `bodhi-update` images could be chosen depending on the region

#### Bare-Metal

* Update Fedora CoreOS default `os_stream` from testing to stable

#### Google Cloud

* Known: Use of stale Fedora CoreOS image may require terraform re-apply during bootstrap ([#687](https://github.com/poseidon/typhoon/pull/687))

#### DigitalOcean

* Rename `image` variable to `os_image` for consistency ([#677](https://github.com/poseidon/typhoon/pull/677)) (action required)

#### Addons

* Update Prometheus from v2.16.0 to [v2.17.1](https://github.com/prometheus/prometheus/releases/tag/v2.17.1)
* Update Grafana from v6.6.2 to [v6.7.1](https://github.com/grafana/grafana/releases/tag/v6.7.1)

## v1.17.4

* Kubernetes [v1.17.4](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.17.md#v1174)
* Update etcd from v3.4.3 to [v3.4.4](https://github.com/etcd-io/etcd/releases/tag/v3.4.4)
  * On Container Linux, fetch using the docker transport format ([#659](https://github.com/poseidon/typhoon/pull/659))
* Update CoreDNS from v1.6.6 to v1.6.7 ([#648](https://github.com/poseidon/typhoon/pull/648))
* Update Calico from v3.12.0 to [v3.13.1](https://docs.projectcalico.org/v3.13/release-notes/)

#### AWS

* Promote Fedora CoreOS to stable ([#668](https://github.com/poseidon/typhoon/pull/668))
* Allow VPC route table extension via reference ([#654](https://github.com/poseidon/typhoon/pull/654))
* Fix `worker_node_labels` on Fedora CoreOS ([#651](https://github.com/poseidon/typhoon/pull/651))
* Fix automatic worker node delete on shutdown on Fedora CoreOS ([#657](https://github.com/poseidon/typhoon/pull/657))

#### Azure

* Upgrade to `terraform-provider-azurerm` [v2.0+](https://www.terraform.io/docs/providers/azurerm/guides/2.0-upgrade-guide.html) (action required)
  * Change `worker_priority` from `Low` to `Spot` if used (action required)
  * Switch to Azure's new Linux VM and Linux VM Scale Set resources
  * Set controller's Azure disk caching to None
  * Associate subnets (in addition to NICs) with security groups (aesthetic)
* Add support for Flatcar Container Linux ([#664](https://github.com/poseidon/typhoon/pull/664))
  * Requires accepting Flatcar Linux Azure Marketplace terms

#### Bare-Metal

* Add `worker_node_labels` map variable for per-worker node labels ([#663](https://github.com/poseidon/typhoon/pull/663))
* Add `worker_node_taints` map variable for per-worker node taints ([#663](https://github.com/poseidon/typhoon/pull/663))

#### DigitalOcean

* Add support for Flatcar Container Linux ([#644](https://github.com/poseidon/typhoon/pull/644))

#### Google Cloud

* Promote Fedora CoreOS to beta ([#668](https://github.com/poseidon/typhoon/pull/668))
* Fix `worker_node_labels` on Fedora CoreOS ([#651](https://github.com/poseidon/typhoon/pull/651))
* Fix automatic worker node delete on shutdown on Fedora CoreOS ([#657](https://github.com/poseidon/typhoon/pull/657))

#### Addons

* Update nginx-ingress from v0.28.0 to [v0.30.0](https://github.com/kubernetes/ingress-nginx/releases/tag/nginx-0.30.0)
* Update Prometheus from v2.15.2 to [v2.16.0](https://github.com/prometheus/prometheus/releases/tag/v2.16.0)
  * Refresh Prometheus rules and alerts
  * Add a BlackboxProbeFailure alert
  * Update kube-state-metrics from v1.9.4 to v1.9.5
  * Update node-exporter from v0.18.1 to [v1.0.0-rc.0](https://github.com/prometheus/node_exporter/releases/tag/v1.0.0-rc.0)
* Update Grafana from v6.6.1 to v6.6.2
  * Refresh Grafana dashboards
* Remove Container Linux Update Operator (CLUO) addon example ([#667](https://github.com/poseidon/typhoon/pull/667))
  * CLUO hasn't been in active use in our clusters and won't be relevant
  beyond Container Linux. Requires patches for use on Kubernetes v1.16+

## v1.17.3

* Kubernetes [v1.17.3](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.17.md#v1173)
* Update Calico from v3.11.2 to v3.12.0
* Allow Fedora CoreOS clusters to pass CNCF conformance suite
  * Set Docker log driver to `json-file` as a workaround
* Try Fedora CoreOS or Flatcar Linux alongside CoreOS [Container Linux](https://coreos.com/os/eol/) clusters (recommended)

#### AWS

* Promote Fedora CoreOS to beta ([#645](https://github.com/poseidon/typhoon/pull/645))

#### Bare-Metal

* Promote Fedora CoreOS to beta ([#645](https://github.com/poseidon/typhoon/pull/645))
* Add Fedora CoreOS kernel arguments initrd and console ([#640](https://github.com/poseidon/typhoon/pull/640))

#### Google Cloud

* Add Terraform module for Fedora CoreOS ([#632](https://github.com/poseidon/typhoon/pull/632))
* Add support for Flatcar Container Linux ([#639](https://github.com/poseidon/typhoon/pull/639))

#### Addons

* Update nginx-ingress from v0.27.1 to v0.28.0
* Update kube-state-metrics from v1.9.3 to v1.9.4
* Update Grafana from v6.5.3 to v6.6.1

## v1.17.2

* Kubernetes [v1.17.2](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.17.md#v1172)

#### AWS

* Promote Fedora CoreOS from preview to alpha

#### Bare-Metal

* Promote Fedora CoreOS from preview to alpha
* Update Fedora CoreOS images location
  * Use Fedora CoreOS production [download](https://getfedora.org/coreos/download/) streams
  * Use live PXE kernel and initramfs images

#### Addons

* Update nginx-ingress from v0.26.1 to [v0.27.1](https://github.com/kubernetes/ingress-nginx/releases/tag/nginx-0.27.1) ([#625](https://github.com/poseidon/typhoon/pull/625))
  * Change runAsUser from 33 to 101 for alpine-based image
* Update kube-state-metrics from v1.9.2 to v1.9.3

## v1.17.1

* Kubernetes [v1.17.1](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.17.md#v1171)
* Update CoreDNS from v1.6.5 to [v1.6.6](https://coredns.io/2019/12/11/coredns-1.6.6-release/) ([#602](https://github.com/poseidon/typhoon/pull/602))
* Update Calico from v3.10.2 to v3.11.2 ([#604](https://github.com/poseidon/typhoon/pull/604))
* Inline Kubelet service on Container Linux nodes ([#606](https://github.com/poseidon/typhoon/pull/606))
* Disable unused Kubelet `127.0.0.1:10248` healthz listener ([#607](https://github.com/poseidon/typhoon/pull/607))
* Enable kube-proxy metrics and allow Prometheus scrapes
  * Allow TCP/10249 traffic with worker node sources

#### AWS

* Update Fedora CoreOS AMI filter for fedora-coreos-31 ([#620](https://github.com/poseidon/typhoon/pull/620))

#### Google

* Allow `terraform-provider-google` v3.0+ ([#617](https://github.com/poseidon/typhoon/pull/617))
  * Only enforce `v2.19+` to ease migration, as no v3.x features are used

#### Addons

* Update Prometheus from v2.14.0 to [v2.15.2](https://github.com/prometheus/prometheus/releases/tag/v2.15.2)
  * Add discovery for kube-proxy service endpoints
* Update kube-state-metrics from v1.8.0 to v1.9.2
* Reduce node-exporter DaemonSet tolerations ([#614](https://github.com/poseidon/typhoon/pull/614))
* Update Grafana from v6.5.1 to v6.5.3

## v1.17.0

* Kubernetes [v1.17.0](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.17.md#v1170)
* Manage clusters without using a local `asset_dir` ([#595](https://github.com/poseidon/typhoon/pull/595))
  * Change `asset_dir` to be optional. Remove the variable to skip writing assets locally (**action recommended**)
  * Allow keeping cluster assets only in Terraform state ([pluggable](https://www.terraform.io/docs/backends/types/remote.html), encryption) and allow `terraform apply` from stateless automation systems
  * Improve asset unpacking on controllers
  * Obtain kubeconfig from Terraform module outputs
* Replace usage of `template_dir` with `templatefile` function ([#587](https://github.com/poseidon/typhoon/pull/587))
  * Require Terraform version v0.12.6+ (**action required**)
* Update CoreDNS from v1.6.2 to v1.6.5 ([#588](https://github.com/poseidon/typhoon/pull/588))
  * Add health `lameduck` option to wait before shutdown
* Update Calico from v3.10.1 to v3.10.2 ([#599](https://github.com/poseidon/typhoon/pull/599))
* Reduce pod eviction timeout for deleting pods on unready nodes from 5m to 1m ([#597](https://github.com/poseidon/typhoon/pull/597))
  * Present since [v1.13.3](#v1133), but mistakenly removed in v1.16.0
* Add CPU requests for control plane static pods ([#589](https://github.com/poseidon/typhoon/pull/589))
  * May provide slight edge case benefits and aligns with upstream

#### Google

* Use new `google_compute_region_instance_group_manager` version block format
  * Fixes warning that `instance_template` is deprecated
  * Require `terraform-provider-google` v2.19.0+ (**action required**)

#### Addons

* Update Grafana from v6.4.4 to [v6.5.1](https://grafana.com/docs/guides/whats-new-in-v6-5/)
* Add pod networking details in dashboards ([#593](https://github.com/poseidon/typhoon/pull/593))
* Add node alerts and Grafana dashboard from node-exporter ([#591](https://github.com/poseidon/typhoon/pull/591))
* Reduce Prometheus high cardinality time series ([#596](https://github.com/poseidon/typhoon/pull/596))

## v1.16.3

* Kubernetes [v1.16.3](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.16.md#v1163)
* Update etcd from v3.4.2 to v3.4.3 ([#582](https://github.com/poseidon/typhoon/pull/582))
* Upgrade Calico from v3.9.2 to [v3.10.1](https://docs.projectcalico.org/v3.10/release-notes/)
  * Allow advertising service ClusterIPs to peer routers via a [BGPConfiguration](https://docs.projectcalico.org/v3.10/networking/advertise-service-ips)
* Switch `kube-proxy` from iptables to ipvs mode ([#574](https://github.com/poseidon/typhoon/pull/574))

#### Addons

* Update Prometheus from v2.13.0 to [v2.14.0](https://github.com/prometheus/prometheus/releases/tag/v2.14.0)
  * Refresh rules, alerts, and dashboards from upstreams
* Remove addon-resizer from kube-state-metrics ([#575](https://github.com/poseidon/typhoon/pull/575))
* Update Grafana from v6.4.2 to v6.4.4

## v1.16.2

* Kubernetes [v1.16.2](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.16.md#v1162)
* Update etcd from v3.4.1 to v3.4.2 ([#570](https://github.com/poseidon/typhoon/pull/570))
* Update Calico from v3.9.1 to [v3.9.2](https://docs.projectcalico.org/v3.9/release-notes/)
  * Default to using Calico and supporting NetworkPolicy on all platforms

#### Azure

* Change default networking provider from "flannel" to "calico" ([#573](https://github.com/poseidon/typhoon/pull/573))

#### Bare-Metal

* Add `controllers` and `workers` as typed lists of machine detail objects ([#566](https://github.com/poseidon/typhoon/pull/566))
  * Define clusters' machines cleanly and with Terraform v0.12 type constraints (**action required**, see PR example)
  * Remove `controller_names`, `controller_macs`, and `controller_domains` variables
  * Remove `worker_names`, `worker_macs`, and `worker_domains` variables

#### DigitalOcean

* Change default networking provider from "flannel" to "calico" ([#573](https://github.com/poseidon/typhoon/pull/573))

#### Addons

* Update Grafana from v6.4.1 to [v6.4.2](https://github.com/grafana/grafana/releases/tag/v6.4.2)
* Change CLUO label from "app" to "name"

## v1.16.1

* Kubernetes [v1.16.1](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.16.md#v1161)
* Update etcd from v3.4.0 to [v3.4.1](https://github.com/etcd-io/etcd/releases/tag/v3.4.1)
* Update Calico from v3.8.2 to [v3.9.1](https://docs.projectcalico.org/v3.9/release-notes/)
* Add Terraform v0.12 variables types ([#553](https://github.com/poseidon/typhoon/pull/553), [#557](https://github.com/poseidon/typhoon/pull/557), [#560](https://github.com/poseidon/typhoon/pull/560), [#556](https://github.com/poseidon/typhoon/pull/556), [#562](https://github.com/poseidon/typhoon/pull/562))
  * Deprecate `cluster_domain_suffix` variable

#### AWS

* Add `worker_node_labels` variable to set initial worker node labels ([#550](https://github.com/poseidon/typhoon/pull/550))
* Add `node_labels` variable to internal `workers` pool module ([#550](https://github.com/poseidon/typhoon/pull/550))
* For Fedora CoreOS, detect most recent AMI in the region

#### Azure

* Promote `networking` provider Calico VXLAN out of experimental (set `networking = "calico"`)
* Add `worker_node_labels` variable to set initial worker node labels ([#550](https://github.com/poseidon/typhoon/pull/550))
* Add `node_labels` variable to internal `workers` pool module ([#550](https://github.com/poseidon/typhoon/pull/550))
* Change `workers` module default `vm_type` to `Standard_DS1_v2` (followup to [#539](https://github.com/poseidon/typhoon/pull/539))

#### Bare-Metal

* For Fedora CoreOS, use new kernel, initrd, and raw paths ([#563](https://github.com/poseidon/typhoon/pull/563))
* Fix Terraform missing comma error ([#549](https://github.com/poseidon/typhoon/pull/549))
* Remove deprecated `container_linux_oem` variable ([#562](https://github.com/poseidon/typhoon/pull/562))

#### DigitalOcean

* Promote `networking` provider Calico VXLAN out of experimental (set `networking = "calico"`)
* Fix Terraform missing comma error ([#549](https://github.com/poseidon/typhoon/pull/549))

#### Google Cloud

* Add `worker_node_labels` variable to set initial worker node labels ([#550](https://github.com/poseidon/typhoon/pull/550))
* Add `node_labels` variable to internal `workers` module ([#550](https://github.com/poseidon/typhoon/pull/550))

#### Addons

* Update Prometheus from v2.12.0 to [v2.13.0](https://github.com/prometheus/prometheus/releases/tag/v2.13.0)
  * Fix Prometheus etcd target discovery and scraping ([#561](https://github.com/poseidon/typhoon/pull/561), regressed with Kubernetes v1.16.0)
* Update kube-state-metrics from v1.7.2 to v1.8.0
* Update nginx-ingress from v0.25.1 to [v0.26.1](https://github.com/kubernetes/ingress-nginx/releases/tag/nginx-0.26.1) ([#555](https://github.com/poseidon/typhoon/pull/555))
  * Add lifecycle hook to allow draining for up to 5 minutes
* Update Grafana from v6.3.5 to [v6.4.1](https://github.com/grafana/grafana/releases/tag/v6.4.1)

## v1.16.0

* Kubernetes [v1.16.0](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.16.md#v1160) ([#543](https://github.com/poseidon/typhoon/pull/543))
  * Read about several Kubernetes API [deprecations](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.16.md#deprecations-and-removals)!
  * Remove legacy node role labels (no longer shown in `kubectl get nodes`)
  * Rename node labels to `node.kubernetes.io/master` and `node.kubernetes.io/node` (migratory)
* Migrate control plane from self-hosted to static pods ([#536](https://github.com/poseidon/typhoon/pull/536))
  * Run `kube-apiserver`, `kube-scheduler`, and `kube-controller-manager` as static pods on each controller
  * `kubectl` edits to `kube-apiserver`, `kube-scheduler`, and `kube-controller-manager` are no longer possible (change)
  * Remove bootkube, self-hosted pivot, and `pod-checkpointer`
* Update CoreDNS from v1.5.0 to v1.6.2 ([#535](https://github.com/poseidon/typhoon/pull/535))
* Update etcd from v3.3.15 to [v3.4.0](https://github.com/etcd-io/etcd/releases/tag/v3.4.0)
* Recommend updating `terraform-provider-ct` plugin from v0.3.2 to [v0.4.0](https://github.com/poseidon/terraform-provider-ct/releases/tag/v0.4.0)

#### Azure

* Change default `controller_type` to `Standard_B2s` ([#539](https://github.com/poseidon/typhoon/pull/539))
  * `B2s` is cheaper by $17/month and provides 2 vCPU, 4GB RAM
* Change default `worker_type` to `Standard_DS1_v2` ([#539](https://github.com/poseidon/typhoon/pull/539))
  * `F1` is previous generation. `DS1_v2` is newer, similar cost, and supports Low Priority mode

#### Addons

* Update Grafana from v6.3.3 to v6.3.5

## v1.15.3

* Kubernetes [v1.15.3](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.15.md#v1153)
* Update etcd from v3.3.13 to [v3.3.15](https://github.com/etcd-io/etcd/releases/tag/v3.3.15)
* Update Calico from v3.8.1 to [v3.8.2](https://docs.projectcalico.org/v3.8/release-notes/)

#### AWS

* Enable root block device encryption by default ([#527](https://github.com/poseidon/typhoon/pull/527))
  * Require `terraform-provider-aws` v2.23+ (**action required**)

#### Addons

* Update Prometheus from v2.11.0 to [v2.12.0](https://github.com/prometheus/prometheus/releases/tag/v2.12.0)
  * Update kube-state-metrics from v1.7.1 to v1.7.2
* Update Grafana from v6.2.5 to v6.3.3
  * Use stable IDs for etcd, CoreDNS, and Nginx Ingress dashboards ([#530](https://github.com/poseidon/typhoon/pull/530))
* Update nginx-ingress from v0.25.0 to [v0.25.1](https://github.com/kubernetes/ingress-nginx/releases/tag/nginx-0.25.1)
  * Fix Nginx security advisories

## v1.15.2

* Kubernetes [v1.15.2](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.15.md#v1152)
* Update Calico from v3.8.0 to [v3.8.1](https://docs.projectcalico.org/v3.8/release-notes/)
* Publish new load balancing, TCP/UDP, and firewall [docs](https://typhoon.psdn.io/architecture/aws/) ([#523](https://github.com/poseidon/typhoon/pull/523))

#### Addons

* Add new Grafana dashboards for CoreDNS and Nginx Ingress Controller ([#525](https://github.com/poseidon/typhoon/pull/525))

## v1.15.1

* Kubernetes [v1.15.1](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.15.md#v1151)
* Upgrade Calico from v3.7.3 to [v3.8.0](https://docs.projectcalico.org/v3.8/release-notes/)
  * Enable CNI `bandwidth` plugin for [traffic shaping](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/#support-traffic-shaping)
* Run `kube-apiserver` with lower privilege user (nobody) ([#506](https://github.com/poseidon/typhoon/pull/506))
* Relax `terraform-provider-ct` version constraint (v0.3.2+)
  * Allow provider versions below v1.0.0 (e.g. upgrading to v0.4)

#### Azure

* Fix to add all controller nodes to the apiserver load balancer backend address pool ([#518](https://github.com/poseidon/typhoon/pull/518))
  * kube-apiserver availability relied on the 0th controller

#### Google Cloud

* Allow controller nodes to span more than 3 zones if available in a region ([#504](https://github.com/poseidon/typhoon/pull/504))
* Eliminate extraneous controller instance groups in single-controller clusters ([#504](https://github.com/poseidon/typhoon/pull/504))
* Raise network deletion timeout from 4m to 6m ([#505](https://github.com/poseidon/typhoon/pull/505))

#### Addons

* Update Prometheus from v2.10.0 to v2.11.0
  * Refresh rules, alerts, and dashboards from upstreams
  * Update kube-state-metrics from v1.6.0 to v1.7.1
* Update Grafana from v6.2.4 to v6.2.5
* Update nginx-ingress from v0.24.1 to v0.25.0
  * Support `networking.k8s.io/v1beta1` apiVersion

## v1.15.0

* Kubernetes [v1.15.0](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.15.md#v1150)
* Migrate from Terraform v0.11 to v0.12.x (**action required!**)
  * [Migration](https://typhoon.psdn.io/topics/maintenance/#terraform-v012x) instructions for Terraform v0.12
* Require `terraform-provider-ct` v0.3.2+ to support Terraform v0.12 (action required)
* Update Calico from v3.7.2 to [v3.7.3](https://docs.projectcalico.org/v3.7/release-notes/)
* Remove Fedora Atomic modules (deprecated in March) ([#501](https://github.com/poseidon/typhoon/pull/501))

#### AWS

* Require `terraform-provider-aws` v2.7+ to support Terraform v0.12 (action required)
* Allow using Flatcar Linux Edge by setting `os_image` to "flatcar-edge"

#### Azure

* Require `terraform-provider-azurerm` v1.27+ to support Terraform v0.12 (action required)
* Avoid unneeded rotations of Regular priority virtual machine scale sets
  * Azure only allows `eviction_policy` to be set for Low priority VMs. Supporting Low priority VMs meant when Regular VMs were used, each `terraform apply` rolled workers, to set eviction_policy to null.
  * Terraform v0.12 nullable variables fix the issue so plan does not produce a diff.

#### Bare-Metal

* Require `terraform-provider-matchbox` v0.3.0+ to support Terraform v0.12 (action required)
* Allow using Flatcar Linux Edge by setting `os_channel` to "flatcar-edge"

#### DigitalOcean

* Require `terraform-provider-digitalocean` v1.3+ to support Terraform v0.12 (action required)
* Change the default `worker_type` from `s-1vcpu1-1gb` to `s-1vcpu-2gb`

#### Google Cloud

* Require `terraform-provider-google` v2.5+ to support Terraform v0.12 (action required)

#### Addons

* Update Grafana from v6.2.1 to v6.2.4
* Update node-exporter from v0.18.0 to v0.18.1

## v1.14.3

* Kubernetes [v1.14.3](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.14.md#v1143)
* Update CoreDNS from v1.3.1 to v1.5.0
  * Add `ready` plugin to improve readinessProbe
* Fix trailing slash in terraform-render-bootkube version ([#479](https://github.com/poseidon/typhoon/pull/479))
* Recommend updating `terraform-provider-ct` plugin from v0.3.1 to [v0.3.2](https://github.com/poseidon/terraform-provider-ct/releases/tag/v0.3.2) ([#487](https://github.com/poseidon/typhoon/pull/487))

#### AWS

* Rename `worker` pool module `count` variable to `worker_count` ([#485](https://github.com/poseidon/typhoon/pull/485)) (action required)
  * `count` will become a reserved variable name in Terraform v0.12

#### Azure

* Replace `azurerm_autoscale_setting` with `azurerm_monitor_autoscale_setting` ([#482](https://github.com/poseidon/typhoon/pull/482))
* Rename `worker` pool module `count` variable to `worker_count` ([#485](https://github.com/poseidon/typhoon/pull/485)) (action required)
  * `count` will become a reserved variable name in Terraform v0.12

#### Bare-Metal

* Recommend updating `terraform-provider-matchbox` plugin from v0.2.3 to [v0.3.0](https://github.com/poseidon/terraform-provider-matchbox/releases/tag/v0.3.0) ([#487](https://github.com/poseidon/typhoon/pull/487))

#### Google Cloud

* Rename `worker` pool module `count` variable to `worker_count` ([#485](https://github.com/poseidon/typhoon/pull/485)) (action required)
  * `count` is a reserved variable in Terraform v0.12

#### Addons

* Update Prometheus from v2.9.2 to v2.10.0
* Update Grafana from v6.1.6 to v6.2.1

## v1.14.2

* Kubernetes [v1.14.2](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.14.md#v1142)
* Update etcd from v3.3.12 to [v3.3.13](https://github.com/etcd-io/etcd/releases/tag/v3.3.13)
* Upgrade Calico from v3.6.1 to [v3.7.2](https://docs.projectcalico.org/v3.7/release-notes/)
* Change flannel VXLAN port from 8472 (kernel default) to 4789 (IANA VXLAN)

#### AWS

* Only set internal VXLAN rules when `networking` is "flannel" (default: calico)

#### Azure

* Allow choosing Calico as the network provider (experimental) ([#472](https://github.com/poseidon/typhoon/pull/472))
  * Add a `networking` variable accepting "flannel" (default) or "calico"
  * Use VXLAN encapsulation since Azure doesn't support IPIP

#### DigitalOcean

* Allow choosing Calico as the network provider (experimental) ([#472](https://github.com/poseidon/typhoon/pull/472))
  * Add a `networking` variable accepting "flannel" (default) or "calico"
  * Use VXLAN encapsulation since DigitalOcean doesn't support IPIP
* Add explicit ordering between firewall rule creation and secure copying Kubelet credentials ([#469](https://github.com/poseidon/typhoon/pull/469))
  * Fix race scenario if copies to nodes were before rule creation, blocking cluster creation

#### Addons

* Update Prometheus from v2.8.1 to v2.9.2
  * Update kube-state-metrics from v1.5.0 to v1.6.0
* Update node-exporter from v0.17.0 to v0.18.0
* Update Grafana from v6.1.3 to v6.1.6
* Reduce nginx-ingress Role RBAC permissions ([#458](https://github.com/poseidon/typhoon/pull/458))

## v1.14.1

* Kubernetes [v1.14.1](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.14.md#v1141)

#### Addons

* Update Grafana from v6.1.1 to v6.1.3
* Update nginx-ingress from v0.23.0 to v0.24.1

## v1.14.0

* Kubernetes [v1.14.0](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.14.md#v1140)
* Update Calico from v3.6.0 to v3.6.1
* Add `enable_aggregation` option for CNCF conformance ([#436](https://github.com/poseidon/typhoon/pull/436))
  * Aggregation is disabled by default to retain our security stance
  * Aggregation increases the security surface area. Extensions become part of the control plane and must be scrutinized carefully and trusted. Favor leaving aggregation disabled.

#### AWS

* Add ability to load balance TCP applications ([#443](https://github.com/poseidon/typhoon/pull/443))
  * Output the network load balancer ARN as `nlb_id`
  * Accept a `worker_target_groups` (ARN) list to which worker instances should be added

#### Azure

* Add ability to load balance TCP/UDP applications ([#447](https://github.com/poseidon/typhoon/pull/447))
  * Output the load balancer ID as `loadbalancer_id`
* Output `worker_security_group_name` and `worker_address_prefix` for extending firewall rules ([#447](https://github.com/poseidon/typhoon/pull/447))

#### DigitalOcean

* Harden internal (node-to-node) firewall rules to align with other platforms ([#444](https://github.com/poseidon/typhoon/pull/444))
* Add ability to load balance TCP applications ([#444](https://github.com/poseidon/typhoon/pull/444))
  * Output `controller_tag` and `worker_tag` for extending firewall rules ([#444](https://github.com/poseidon/typhoon/pull/444))

#### Google Cloud

* Add ability to load balance TCP/UDP applications ([#442](https://github.com/poseidon/typhoon/pull/442))
  * Add worker instances to a target pool, output as `worker_target_pool`
  * Health check for workers with Ingress controllers. Forward rules don't support differing internal/external ports, but some Ingress controllers support TCP/UDP proxy as a workaround
* Remove Haswell minimum CPU platform requirement ([#439](https://github.com/poseidon/typhoon/pull/439))
  * Google Cloud API implements `min_cpu_platform` to mean "use exactly this CPU". Revert [#405](https://github.com/poseidon/typhoon/pull/405) added in v1.13.4.
  * Fix error creating clusters in new regions without Haswell (e.g. europe-west2) ([#438](https://github.com/poseidon/typhoon/issues/438))

#### Addons

* Update Prometheus from v2.8.0 to v2.8.1
* Update Grafana from v6.0.2 to [v6.1.1](http://docs.grafana.org/guides/whats-new-in-v6-1/)
  * Add dashboard for pods in a workload (deployment/daemonset/statefulset) ([#446](https://github.com/poseidon/typhoon/pull/446))
  * Add dashboard for workloads by namespace

## v1.13.5

* Kubernetes [v1.13.5](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.13.md#v1135)
* Resolve in-addr.arpa reverse DNS lookups (PTR) for pod IPv4 addresses ([#415](https://github.com/poseidon/typhoon/pull/415))
  * Reverse DNS lookups for service IPv4 addresses unchanged
* Upgrade Calico from v3.5.2 to [v3.6.0](https://docs.projectcalico.org/v3.6/release-notes/) ([#430](https://github.com/poseidon/typhoon/pull/430))
  * Change pod IPAM from `host-local` to `calico-ipam`. `pod_cidr` is still divided into `/24` subnets per node, but managed as `ippools` and `ipamblocks`
* Recommend updating [terraform-provider-ct](https://github.com/poseidon/terraform-provider-ct) from v0.3.0 to [v0.3.1](https://github.com/poseidon/terraform-provider-ct/releases/tag/v0.3.1) ([#434](https://github.com/poseidon/typhoon/pull/434))
* Announce: Fedora Atomic modules will be not be updated beyond Kubernetes v1.13.x ([#437](https://github.com/poseidon/typhoon/pull/437))
  * Thank you Project Atomic team and users, please see the deprecation [notice](https://typhoon.psdn.io/announce/#march-27-2019)

#### AWS

* Support `terraform-provider-aws` v2.0+ ([#419](https://github.com/poseidon/typhoon/pull/419))

#### Bare-Metal

* Change the default iPXE kernel and initrd download protocol from HTTP to HTTPS ([#420](https://github.com/poseidon/typhoon/pull/420))
  * Require an iPXE-enabled network boot environment with support for TLS downloads. PXE clients must chainload to iPXE firmware compiled with `DOWNLOAD_PROTO_HTTPS` [enabled](https://ipxe.org/crypto). (**action required**)
  * Only affects Container Linux and Flatcar Linux install profiles that pull public images (default)
  * Add `download_protocol` variable. Recognizing boot firmware TLS support is difficult in some environments, set the protocol to "http" for the old behavior (discouraged)

#### DigitalOcean

* Fix kubelet hostname-override to set node metadata InternalIP correctly ([#424](https://github.com/poseidon/typhoon/issues/424))
  * Uniquely, DigitalOcean does not resolve hostnames to instance private IPs. Kubelet auto-detect mechanisms require the internal IP be set directly.
  * Regressed in v1.12.3 ([#337](https://github.com/poseidon/typhoon/pull/337)) which aimed to provide friendly hostname-based node names on DigitalOcean

#### Addons

* Update Prometheus from v2.7.1 to [v2.8.0](https://github.com/prometheus/prometheus/releases/tag/v2.8.0)
  * Refresh rules based on upstreams ([#426](https://github.com/poseidon/typhoon/pull/426))
  * Define NetworkPolicy to allow only traffic from the Grafana addon
* Update Grafana from v6.0.0 to v6.0.2
  * Add liveness and readiness probes
  * Refresh dashboards and organize to stay below ConfigMap size limit ([#426](https://github.com/poseidon/typhoon/pull/426))
* Remove heapster manifests from addons ([#427](https://github.com/poseidon/typhoon/pull/427))
  * Heapster addon powers `kubectl top` (in early Kubernetes, running the addon was expected). Today, there are better monitoring options.
  * `kubectl top` reliance on a non-core extension means its not in-scope for minimal Kubernetes
  * Look to prior releases if you still wish to apply heapster

## v1.13.4

* Kubernetes [v1.13.4](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.13.md#v1134)
* Update etcd from v3.3.11 to [v3.3.12](https://github.com/etcd-io/etcd/releases/tag/v3.3.12)
* Update Calico from v3.5.0 to [v3.5.2](https://docs.projectcalico.org/v3.5/releases/)
* Assign priorityClassNames to critical cluster and node components ([#406](https://github.com/poseidon/typhoon/pull/406))
  * Inform node out-of-resource eviction and scheduler preemption and ordering
* Add CoreDNS readiness probe ([#410](https://github.com/poseidon/typhoon/pull/410))

#### Bare-Metal

* Recommend updating [terraform-provider-matchbox](https://github.com/poseidon/terraform-provider-matchbox) plugin from v0.2.2 to [v0.2.3](https://github.com/poseidon/terraform-provider-matchbox/releases/tag/v0.2.3) ([#402](https://github.com/poseidon/typhoon/pull/402))
* Improve docs on using Ubiquiti EdgeOS with bare-metal clusters ([#413](https://github.com/poseidon/typhoon/pull/413))

#### Google Cloud

* Support `terraform-provider-google` v2.0+ ([#407](https://github.com/poseidon/typhoon/pull/407))
  * Require `terraform-provider-google` v1.19+ (**action required**)
* Set the minimum CPU platform to Intel Haswell ([#405](https://github.com/poseidon/typhoon/pull/405))
  * Haswell or better is available in every zone (no price change)
  * A few zones still default to Sandy/Ivy Bridge (shifts in April 2019)

#### Addons

* Modernize Prometheus rules and alerts ([#404](https://github.com/poseidon/typhoon/pull/404))
  * Drop extraneous metrics ([#397](https://github.com/poseidon/typhoon/pull/397))
  * Add `pod` name label to metrics discovered via service endpoints
  * Rename `kubernetes_namespace` label to `namespace`
* Modernize Grafana and dashboards, see [docs](https://typhoon.psdn.io/addons/grafana/) ([#403](https://github.com/poseidon/typhoon/pull/403), [#404](https://github.com/poseidon/typhoon/pull/404))
  * Upgrade Grafana from v5.4.3 to [v6.0.0](https://github.com/grafana/grafana/releases/tag/v6.0.0)!
  * Enable Grafana [Explore](http://docs.grafana.org/guides/whats-new-in-v6-0/#explore) UI as a Viewer (inspect/edit without saving)
* Update nginx-ingress from v0.22.0 to v0.23.0
  * Raise nginx-ingress liveness/readiness timeout to 5 seconds
  * Remove nginx-ingess default-backend ([#401](https://github.com/poseidon/typhoon/pull/401))

#### Fedora Atomic

* Build Kubelet [system container](https://github.com/poseidon/system-containers) with buildah. The image is an OCI format and slightly larger.

## v1.13.3

* Kubernetes [v1.13.3](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.13.md#v1133)
* Update etcd from v3.3.10 to [v3.3.11](https://github.com/etcd-io/etcd/blob/master/CHANGELOG-3.3.md#v3311-2019-1-11)
* Update CoreDNS from v1.3.0 to [v1.3.1](https://coredns.io/2019/01/13/coredns-1.3.1-release/)
  * Switch from the `proxy` plugin to the faster `forward` plugin for upsteam resolvers
* Update Calico from v3.4.0 to [v3.5.0](https://docs.projectcalico.org/v3.5/releases/)
* Update flannel from v0.10.0 to [v0.11.0](https://github.com/coreos/flannel/releases/tag/v0.11.0)
* Reduce pod eviction timeout for deleting pods on unready nodes to 1 minute
  * Respond more quickly to node preemption (previously 5 minutes)
* Fix automatic worker deletion on shutdown for cloud platforms
  * Lowering Kubelet privileges in [#372](https://github.com/poseidon/typhoon/pull/372) dropped a needed node deletion authorization. Scale-in due to manual terraform apply (any cloud), AWS spot termination, or Azure low priority deletion left old nodes registered, requiring manual deletion (`kubectl delete node name`)

#### AWS

* Add `ingress_zone_id` output with the NLB DNS name's Route53 zone for use in alias records ([#380](https://github.com/poseidon/typhoon/pull/380))

#### Azure

* Fix azure provider warning, `public_ip` `allocation_method` replaces `public_ip_address_allocation`
  * Require `terraform-provider-azurerm` v1.21+ (action required)

#### Addons

* Update nginx-ingress from v0.21.0 to v0.22.0
* Update Prometheus from v2.6.0 to v2.7.1
* Update kube-state-metrics from v1.4.0 to v1.5.0
  * Fix ClusterRole to collect and export PodDisruptionBudget metrics ([#383](https://github.com/poseidon/typhoon/pull/383))
* Update node-exporter from v0.15.2 to v0.17.0
* Update Grafana from v5.4.2 to v5.4.3

## v1.13.2

* Kubernetes [v1.13.2](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.13.md#v1132)
* Add ServiceAccounts for `kube-apiserver` and `kube-scheduler` ([#370](https://github.com/poseidon/typhoon/pull/370))
* Use lower-privilege TLS client certificates for Kubelets ([#372](https://github.com/poseidon/typhoon/pull/372))
* Use HTTPS liveness probes for `kube-scheduler` and `kube-controller-manager` ([#377](https://github.com/poseidon/typhoon/pull/377))
* Update CoreDNS from v1.2.6 to [v1.3.0](https://coredns.io/2018/12/15/coredns-1.3.0-release/)
* Allow the `certificates.k8s.io` API to issue certificates signed by the cluster CA ([#376](https://github.com/poseidon/typhoon/pull/376))
  * Configure controller manager to sign CSRs that are manually [approved](https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster) by an administrator

#### AWS

* Change `controller_type` and `worker_type` default from t2.small to t3.small ([#365](https://github.com/poseidon/typhoon/pull/365))
  * t3.small is cheaper, provides 2 vCPU (instead of 1), and 5 Gbps of pod-to-pod bandwidth!

#### Bare-Metal

* Remove the `kubeconfig` output variable

#### Addons

* Update Prometheus from v2.5.0 to v2.6.0

## v1.13.1

* Kubernetes [v1.13.1](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.13.md#v1131)
* Update Calico from v3.3.2 to [v3.4.0](https://docs.projectcalico.org/v3.4/releases/) ([#362](https://github.com/poseidon/typhoon/pull/362))
  * Install CNI plugins with an init container rather than a sidecar
  * Improve the `calico-node` ClusterRole
* Recommend updating `terraform-provider-ct` plugin from v0.2.1 to v0.3.0 ([#363](https://github.com/poseidon/typhoon/pull/363))
  * [Migration](https://typhoon.psdn.io/topics/maintenance/#upgrade-terraform-provider-ct) instructions for upgrading `terraform-provider-ct` in-place for v1.12.2+ clusters (**action required**)
  * [Require](https://typhoon.psdn.io/topics/maintenance/#terraform-plugins-directory) switching from `~/.terraformrc` to the Terraform [third-party plugins](https://www.terraform.io/docs/configuration/providers.html#third-party-plugins) directory `~/.terraform.d/plugins/`
  * Require Container Linux 1688.5.3 or newer

#### Google Cloud

* Increase TCP proxy apiserver backend service timeout from 1 minute to 5 minutes ([#361](https://github.com/poseidon/typhoon/pull/361))
  * Align `port-forward` behavior closer to AWS/Azure (no timeout)

#### Addons

* Update Grafana from v5.4.0 to v5.4.2

## v1.13.0

* Kubernetes [v1.13.0](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.13.md#v1130)
* Update Calico from v3.3.1 to [v3.3.2](https://docs.projectcalico.org/v3.3/releases/)

#### Addons

* Update Grafana from v5.3.4 to v5.4.0
* Disable Grafana login form, since admin user can't be disabled ([#352](https://github.com/poseidon/typhoon/pull/352))
  * Example manifests aim to provide a read-only dashboard view

## v1.12.3

* Kubernetes [v1.12.3](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.12.md#v1123)
* Add `enable_reporting` variable (default "false") to provide upstreams with usage data ([#345](https://github.com/poseidon/typhoon/pull/345))
* Change kube-apiserver `--kubelet-preferred-address-types` to InternalIP,ExternalIP,Hostname
* Update Calico from v3.3.0 to [v3.3.1](https://docs.projectcalico.org/v3.3/releases/)
  * Disable Felix usage reporting by default ([#345](https://github.com/poseidon/typhoon/pull/345))
* Improve flannel manifests
  * [Rename](https://github.com/poseidon/terraform-render-bootkube/commit/d045a8e6b8eccfbb9d69bb51953b5a93d23f67f7) `kube-flannel` DaemonSet to `flannel` and `kube-flannel-cfg` ConfigMap to `flannel-config`
  * [Drop](https://github.com/poseidon/terraform-render-bootkube/commit/39f9afb3360ec642e5b98457c8bd07eda35b6c96) unused mounts and add a CPU resource request
* Update CoreDNS from v1.2.4 to [v1.2.6](https://coredns.io/2018/11/05/coredns-1.2.6-release/)
  * Enable CoreDNS `loop` and `loadbalance` plugins ([#340](https://github.com/poseidon/typhoon/pull/340))
* Fix pod-checkpointer log noise and checkpointable pods detection ([#346](https://github.com/poseidon/typhoon/pull/346))
* Use kubernetes-incubator/bootkube v0.14.0
* [Recommend](https://typhoon.psdn.io/topics/maintenance/#terraform-plugins-directory) switching from `~/.terraformrc` to the Terraform [third-party plugins](https://www.terraform.io/docs/configuration/providers.html#third-party-plugins) directory `~/.terraform.d/plugins/`.
  * Allows pinning `terraform-provider-ct` and `terraform-provider-matchbox` versions
  * Improves safety of later plugin version migrations

#### Azure

* Use eviction policy `Delete` for `Low` priority virtual machine scale set workers ([#343](https://github.com/poseidon/typhoon/pull/343))
  * Fix issue where Azure defaults to `Deallocate` eviction policy, which required manually restarting deallocated instances. `Delete` policy aligns Azure with AWS and GCP behavior.
  * Require `terraform-provider-azurerm` v1.19+ (action required)

#### Bare-Metal

* Add Kubelet `/etc/iscsi` and `iscsadm` mounts on bare-metal for iSCSI ([#103](https://github.com/poseidon/typhoon/pull/103))

#### Addons

* Update nginx-ingress from v0.20.0 to v0.21.0
* Update Prometheus from v2.4.3 to v2.5.0
* Update Grafana from v5.3.2 to v5.3.4

## v1.12.2

* Kubernetes [v1.12.2](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.12.md#v1122)
* Update CoreDNS from 1.2.2 to [1.2.4](https://github.com/coredns/coredns/releases/tag/v1.2.4)
* Update Calico from v3.2.3 to [v3.3.0](https://docs.projectcalico.org/v3.3/releases/)
* Disable Kubelet read-only port ([#324](https://github.com/poseidon/typhoon/pull/324))
* Fix CoreDNS AntiAffinity spec to prefer spreading replicas
* Ignore controller node user-data changes ([#335](https://github.com/poseidon/typhoon/pull/335))
  * Once all managed clusters use v1.12.2, it is possible to update `terraform-provider-ct`

#### AWS

* Add `disk_iops` variable for EBS volume IOPS ([#314](https://github.com/poseidon/typhoon/pull/314))

#### Azure

* Use new `azurerm_network_interface_backend_address_pool_association` ([#332](https://github.com/poseidon/typhoon/pull/332))
  * Require `terraform-provider-azurerm` v1.17+ (action required)
* Add `primary` field to `ip_configuration` needed by v1.17+ ([#331](https://github.com/poseidon/typhoon/pull/331))

#### DigitalOcean

* Add AAAA DNS records resolving to worker nodes ([#333](https://github.com/poseidon/typhoon/pull/333))
  * Hosting IPv6 apps requires editing nginx-ingress with `hostNetwork: true`

#### Google Cloud

* Add an IPv6 address and IPv6 forwarding rules for load balancing IPv6 Ingress ([#334](https://github.com/poseidon/typhoon/pull/334))
  * Add `ingress_static_ipv6` output variable for use in AAAA DNS records
  * Allow serving IPv6 applications via Kubernetes Ingress

#### Addons

* Configure Heapster to scrape Kubelets with bearer token auth ([#323](https://github.com/poseidon/typhoon/pull/323))
* Update Grafana from v5.3.1 to v5.3.2

## v1.12.1

* Kubernetes [v1.12.1](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.12.md#v1121)
* Update etcd from v3.3.9 to [v3.3.10](https://github.com/etcd-io/etcd/blob/master/CHANGELOG-3.3.md#v3310-2018-10-10)
* Update CoreDNS from 1.1.3 to [1.2.2](https://github.com/coredns/coredns/releases/tag/v1.2.2)
* Update Calico from v3.2.1 to [v3.2.3](https://docs.projectcalico.org/v3.2/releases/)
* Raise scheduler and controller-manager replicas to the larger of 2 or the number of controller nodes ([#312](https://github.com/poseidon/typhoon/pull/312))
  * Single-controller clusters continue to run 2 replicas as before
* Raise default CoreDNS replicas to the larger of 2 or the number of controller nodes ([#313](https://github.com/poseidon/typhoon/pull/313))
  * Add AntiAffinity preferred rule to favor spreading CoreDNS pods
* Annotate control plane and addon containers to use the Docker runtime seccomp profile ([#319](https://github.com/poseidon/typhoon/pull/319))
  * Override Kubernetes default behavior that starts containers with `seccomp=unconfined`

#### Azure

* Remove `admin_password` field (disabled) since it is now optional
  * Require `terraform-provider-azurerm` v1.16+ (action required)

#### Bare-Metal

* Add support for `cached_install` mode with Flatcar Linux ([#315](https://github.com/poseidon/typhoon/pull/315))

#### DigitalOcean

* Require `terraform-provider-digitalocean` v1.0+ (action required)

#### Addons

* Update nginx-ingress from v0.19.0 to v0.20.0
* Update Prometheus from v2.3.2 to v2.4.3
* Update Grafana from v5.2.4 to v5.3.1

## v1.11.3

* Kubernetes [v1.11.3](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.11.md#v1113)
* Introduce Typhoon for Azure as alpha ([#288](https://github.com/poseidon/typhoon/pull/288))
  * Special thanks @justaugustus for an earlier variant
* Update Calico from v3.1.3 to v3.2.1 ([#278](https://github.com/poseidon/typhoon/pull/278))

#### AWS

* Remove firewall rule allowing ICMP packets to nodes ([#285](https://github.com/poseidon/typhoon/pull/285))

#### Bare-Metal

* Remove `controller_networkds` and `worker_networkds` variables. Use Container Linux Config snippets [#277](https://github.com/poseidon/typhoon/pull/277)

#### Google Cloud

* Fix firewall to allow etcd client port 2379 traffic between controller nodes ([#287](https://github.com/poseidon/typhoon/pull/287))
  * kube-apiservers were only able to connect to their node's local etcd peer. While master node outages were tolerated, reaching a healthy peer took longer than neccessary in some cases
  * Reduce time needed to bootstrap the cluster
* Remove firewall rule allowing workers to access Nginx Ingress health check ([#284](https://github.com/poseidon/typhoon/pull/284))
  * Nginx Ingress addon no longer uses hostNetwork, Prometheus scrapes via CNI network

#### Addons

* Update nginx-ingress from 0.17.1 to 0.19.0
* Update kube-state-metrics from v1.3.1 to v1.4.0
* Update Grafana from 5.2.2 to 5.2.4

## v1.11.2

* Kubernetes [v1.11.2](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.11.md#v1112)
* Update etcd from v3.3.8 to [v3.3.9](https://github.com/coreos/etcd/blob/master/CHANGELOG-3.3.md#v339-2018-07-24)
* Use kubernetes-incubator/bootkube v0.13.0
* Fix Fedora Atomic modules' Kubelet version ([#270](https://github.com/poseidon/typhoon/issues/270))

#### Bare-Metal

* Introduce [Container Linux Config snippets](https://typhoon.psdn.io/advanced/customization/#container-linux) on bare-metal
  * Validate and additively merge custom Container Linux Configs during terraform plan
  * Define files, systemd units, dropins, networkd configs, mounts, users, and more
  * [Require](https://typhoon.psdn.io/cl/bare-metal/#terraform-setup) `terraform-provider-ct` plugin v0.2.1 (**action required!**)

#### Addons

* Update nginx-ingress from 0.16.2 to 0.17.1
* Add nginx-ingress manifests for bare-metal
* Update Grafana from 5.2.1 to 5.2.2
* Update heapster from v1.5.3 to v1.5.4

## v1.11.1

* Kubernetes [v1.11.1](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.11.md#v1111)

#### Addons

* Update Prometheus from v2.3.1 to v2.3.2

#### Errata

* Fedora Atomic modules shipped with Kubelet v1.11.0, instead of v1.11.1. Fixed in [#270](https://github.com/poseidon/typhoon/issues/270).

## v1.11.0

* Kubernetes [v1.11.0](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.11.md#v1110)
* Force apiserver to stop listening on `127.0.0.1:8080`
* Replace `kube-dns` with [CoreDNS](https://coredns.io/) ([#261](https://github.com/poseidon/typhoon/pull/261))
  * Edit the `coredns` ConfigMap to [customize](https://coredns.io/plugins/)
  * CoreDNS doesn't use a resizer. For large clusters, scaling may be required.

#### AWS

* Update from Fedora Atomic 27 to 28 ([#258](https://github.com/poseidon/typhoon/pull/258))

#### Bare-Metal

* Update from Fedora Atomic 27 to 28 ([#263](https://github.com/poseidon/typhoon/pull/263))

#### Google

* Promote Google Cloud to stable
* Update from Fedora Atomic 27 to 28 ([#259](https://github.com/poseidon/typhoon/pull/259))
* Remove `ingress_static_ip` module output. Use `ingress_static_ipv4`.
* Remove `controllers_ipv4_public` module output.

#### Addons

* Update nginx-ingress from 0.15.0 to 0.16.2
* Update Grafana from 5.1.4 to [5.2.1](http://docs.grafana.org/guides/whats-new-in-v5-2/)
* Update heapster from v1.5.2 to v1.5.3

## v1.10.5

* Kubernetes [v1.10.5](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.10.md#v1105)
* Update etcd from v3.3.6 to v3.3.8 ([#243](https://github.com/poseidon/typhoon/pull/243), [#247](https://github.com/poseidon/typhoon/pull/247))

#### AWS

* Switch `kube-apiserver` port from 443 to 6443 ([#248](https://github.com/poseidon/typhoon/pull/248))
* Combine apiserver and ingress NLBs ([#249](https://github.com/poseidon/typhoon/pull/249))
  * Reduce cost by ~$18/month per cluster. Typhoon AWS clusters now use one network load balancer.
  * Ingress addon users may keep using CNAME records to the `ingress_dns_name` module output (few million RPS)
  * Ingress users with heavy traffic (many million RPS) should create a separate NLB(s)
* Worker pools no longer include an extraneous load balancer. Remove worker module's `ingress_dns_name` output
* Disable detailed (paid) monitoring on worker nodes ([#251](https://github.com/poseidon/typhoon/pull/251))
  * Favor Prometheus for cloud-agnostic metrics, aggregation, and alerting
* Add `worker_target_group_http` and `worker_target_group_https` module outputs to allow custom load balancing
* Add `target_group_http` and `target_group_https` worker module outputs to allow custom load balancing

#### Bare-Metal

* Switch `kube-apiserver` port from 443 to 6443 ([#248](https://github.com/poseidon/typhoon/pull/248))
  * Users who exposed kube-apiserver on a WAN via their router/load-balancer will need to adjust its configuration (e.g. DNAT 6443). Most apiservers are on a LAN (internal, VPN-only, etc) so if you didn't specially configure network gear for 443, no change is needed. (possible action required)
* Fix possible deadlock when provisioning clusters larger than 10 nodes ([#244](https://github.com/poseidon/typhoon/pull/244))

#### DigitalOcean

* Switch `kube-apiserver` port from 443 to 6443 ([#248](https://github.com/poseidon/typhoon/pull/248))
  * Update firewall rules and generated kubeconfig's

#### Google Cloud

* Use global HTTP and TCP proxy load balancing for Kubernetes Ingress ([#252](https://github.com/poseidon/typhoon/pull/252))
  * Switch Ingress from regional network load balancers to global HTTP/TCP Proxy load balancing
  * Reduce cost by ~$19/month per cluster. Google bills the first 5 global and regional forwarding rules separately. Typhoon clusters now use 3 global and 0 regional forwarding rules.
* Worker pools no longer include an extraneous load balancer. Remove worker module's `ingress_static_ip` output
* Allow using nginx-ingress addon on Fedora Atomic clusters ([#200](https://github.com/poseidon/typhoon/issues/200))
* Add `worker_instance_group` module output to allow custom global load balancing
* Add `instance_group` worker module output to allow custom global load balancing
* Deprecate `ingress_static_ip` module output. Add `ingress_static_ipv4` module output instead.
* Deprecate `controllers_ipv4_public` module output

#### Addons

* Update CLUO from v0.6.0 to v0.7.0 ([#242](https://github.com/poseidon/typhoon/pull/242))
* Update Prometheus from v2.3.0 to v2.3.1
* Update Grafana from 5.1.3 to 5.1.4
* Drop `hostNetwork` from nginx-ingress addon
  * Both flannel and Calico support host port via `portmap`
  * Allows writing NetworkPolicies that reference ingress pods in `from` or `to`. HostNetwork pods were difficult to write network policy for since they could circumvent the CNI network to communicate with pods on the same node.

## v1.10.4

* Kubernetes [v1.10.4](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.10.md#v1104)
* Update etcd from v3.3.5 to v3.3.6
* Update Calico from v3.1.2 to v3.1.3

#### Addons

* Update Prometheus from v2.2.1 to v2.3.0
* Add Prometheus liveness and readiness probes
* Annotate Grafana service so Prometheus scrapes metrics
* Label namespaces to ease writing Network Policies

## v1.10.3

* Kubernetes [v1.10.3](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.10.md#v1103)
* Add [Flatcar Linux](https://docs.flatcar-linux.org/) (Container Linux derivative) as an option for AWS and bare-metal (thanks @kinvolk folks)
* Allow bearer token authentication to the Kubelet ([#216](https://github.com/poseidon/typhoon/issues/216))
  * Require Webhook authorization to the Kubelet
  * Switch apiserver X509 client cert org to satisfy new authorization requirement
* Require Terraform v0.11.x and drop support for v0.10.x ([migration guide](https://typhoon.psdn.io/topics/maintenance/#terraform-v011x))
* Update etcd from v3.3.4 to v3.3.5 ([#213](https://github.com/poseidon/typhoon/pull/213))
* Update Calico from v3.1.1 to v3.1.2

#### AWS

* Allow Flatcar Linux by setting `os_image` to flatcar-stable (default), flatcar-beta, flatcar-alpha ([#211](https://github.com/poseidon/typhoon/pull/211))
* Replace `os_channel` variable with `os_image` to align naming across clouds
  * Please change values stable, beta, or alpha to coreos-stable, coreos-beta, coreos-alpha (**action required!**)
* Allow preemptible workers via spot instances ([#202](https://github.com/poseidon/typhoon/pull/202))
  * Add `worker_price` to allow worker spot instances. Default to empty string for the worker autoscaling group to use regular on-demand instances
  * Add `spot_price` to internal `workers` module for spot [worker pools](https://typhoon.psdn.io/advanced/worker-pools/)

#### Bare-Metal

* Allow Flatcar Linux by setting `os_channel` to flatcar-stable, flatcar-beta, flatcar-alpha ([#220](https://github.com/poseidon/typhoon/pull/220))
* Replace `container_linux_channel` variable with `os_channel`
  * Please change values stable, beta, or alpha to coreos-stable, coreos-beta, coreos-alpha (**action required!**)
* Replace `container_linux_version` variable with `os_version`
* Add `network_ip_autodetection_method` variable for Calico host IPv4 address detection
  * Use Calico's default "first-found" to support single NIC and bonded NIC nodes
  * Allow [alternative](https://docs.projectcalico.org/v3.1/reference/node/configuration#ip-autodetection-methods) methods for multi NIC nodes, like can-reach=IP or interface=REGEX
* Deprecate `container_linux_oem` variable

#### DigitalOcean

* Update Fedora Atomic module to use Fedora Atomic 28 ([#225](https://github.com/poseidon/typhoon/pull/225))
  * Fedora Atomic 27 images disappeared from DigitalOcean and forced this early update

#### Addons

* Fix Prometheus data directory location ([#203](https://github.com/poseidon/typhoon/pull/203))
* Configure Prometheus to scrape Kubelets directly with bearer token auth instead of proxying through the apiserver ([#217](https://github.com/poseidon/typhoon/pull/217))
  * Security improvement: Drop RBAC permission from `nodes/proxy` to `nodes/metrics`
  * Scale: Remove per-node proxied scrape load from the apiserver
* Update Grafana from v5.04 to v5.1.3 ([#208](https://github.com/poseidon/typhoon/pull/208))
  * Disable Grafana Google Analytics by default ([#214](https://github.com/poseidon/typhoon/issues/214))
* Update nginx-ingress from 0.14.0 to 0.15.0
* Annotate nginx-ingress service so Prometheus auto-discovers and scrapes service endpoints ([#222](https://github.com/poseidon/typhoon/pull/222))

## v1.10.2

* Kubernetes [v1.10.2](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.10.md#v1102)
* [Introduce](https://typhoon.psdn.io/announce/#april-26-2018) Typhoon for Fedora Atomic ([#199](https://github.com/poseidon/typhoon/pull/199))
* Update Calico from v3.0.4 to v3.1.1 ([#197](https://github.com/poseidon/typhoon/pull/197))
  * https://www.projectcalico.org/announcing-calico-v3-1/
  * https://github.com/projectcalico/calico/releases/tag/v3.1.0
* Update etcd from v3.3.3 to v3.3.4
* Update kube-dns from v1.14.9 to v1.14.10

#### Google Cloud

* Add support for multi-controller clusters (i.e. multi-master) ([#54](https://github.com/poseidon/typhoon/issues/54), [#190](https://github.com/poseidon/typhoon/pull/190))
  * Switch from Google Cloud network load balancer to a TCP proxy load balancer. Avoid a [bug](https://issuetracker.google.com/issues/67366622) in Google network load balancers that limited clusters to only bootstrapping one controller node.
  * Add TCP health check for apiserver pods on controllers. Replace kubelet check approximation.

#### Addons

* Update nginx-ingress from 0.12.0 to 0.14.0
* Update kube-state-metrics from v1.3.0 to v1.3.1

## v1.10.1

* Kubernetes [v1.10.1](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.10.md#v1101)
* Enable etcd v3.3 metrics endpoint ([#175](https://github.com/poseidon/typhoon/pull/175))
* Use `k8s.gcr.io` instead of `gcr.io/google_containers` ([#180](https://github.com/poseidon/typhoon/pull/180))
  * Kubernetes [recommends](https://groups.google.com/forum/#!msg/kubernetes-dev/ytjk_rNrTa0/3EFUHvovCAAJ) using the alias to pull from the nearest regional mirror and to abstract the backing container registry
* Update etcd from v3.3.2 to v3.3.3
* Update kube-dns from v1.14.8 to v1.14.9
* Use kubernetes-incubator/bootkube v0.12.0

#### Bare-Metal

* Fix need for multiple `terraform apply` runs to create a cluster with Terraform v0.11.4 ([#181](https://github.com/poseidon/typhoon/pull/181))
  * To SSH during a disk install for debugging, SSH as user "core" with port 2222
  * Remove the old trick of using a user "debug" during disk install

#### Google Cloud

* Refactor out the `controller` internal module

#### Addons

* Add Prometheus discovery for etcd peers on controller nodes ([#175](https://github.com/poseidon/typhoon/pull/175))
  * Scrape etcd v3.3 `--listen-metrics-urls` for metrics
  * Enable etcd alerts and populate the etcd Grafana dashboard
* Update kube-state-metrics from v1.2.0 to v1.3.0

## v1.10.0

* Kubernetes [v1.10.0](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.10.md#v1100)
* Remove unused, unmaintained `pxe-worker` internal module

#### AWS

* Add `disk_type` optional variable for setting the EBS volume type ([#176](https://github.com/poseidon/typhoon/pull/176))
  * Change default type from `standard` to `gp2`. Prometheus etcd alerts are tuned for fast disks.

#### Digital Ocean

* Ensure etcd secrets are only distributed to controller hosts, not workers.
* Remove `networking` optional variable. Only flannel works on Digital Ocean.

#### Google Cloud

* Add `disk_size` optional variable for setting instance disk size in GB
* Add `controller_type` optional variable for setting machine type for controllers
* Add `worker_type` optional variable for setting machine type for workers
* Remove `machine_type` optional variable. Use `controller_type` and `worker_type`.

#### Addons

* Update Grafana from v4.6.3 to v5.0.4 ([#153](https://github.com/poseidon/typhoon/pull/153), [#174](https://github.com/poseidon/typhoon/pull/174))
  * Restrict dashboard organization role to Viewer

## v1.9.6

* Kubernetes [v1.9.6](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.9.md#v196)
* Update Calico from v3.0.3 to v3.0.4

#### Addons

* Update heapster from v1.5.1 to v1.5.2

## v1.9.5

* Kubernetes [v1.9.5](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.9.md#v195)
  * Fix `subPath` volume mounts regression ([kubernetes#61076](https://github.com/kubernetes/kubernetes/issues/61076))
* Introduce [Container Linux Config snippets](https://typhoon.psdn.io/advanced/customization/#container-linux) on cloud platforms ([#145](https://github.com/poseidon/typhoon/pull/145))
  * Validate and additively merge custom Container Linux Configs during `terraform plan`
  * Define files, systemd units, dropins, networkd configs, mounts, users, and more
  * Require updating `terraform-provider-ct` plugin from v0.2.0 to v0.2.1
* Add `node-role.kubernetes.io/controller="true"` node label to controllers ([#160](https://github.com/poseidon/typhoon/pull/160))

#### AWS

* [Require](https://typhoon.psdn.io/topics/maintenance/#terraform-provider-ct-v021) updating `terraform-provider-ct` plugin from v0.2.0 to [v0.2.1](https://github.com/poseidon/terraform-provider-ct/releases/tag/v0.2.1) (action required!)

#### Digital Ocean

* [Require](https://typhoon.psdn.io/topics/maintenance/#terraform-provider-ct-v021) updating `terraform-provider-ct` plugin from v0.2.0 to [v0.2.1](https://github.com/poseidon/terraform-provider-ct/releases/tag/v0.2.1) (action required!)

#### Google Cloud

* [Require](https://typhoon.psdn.io/topics/maintenance/#terraform-provider-ct-v021) updating `terraform-provider-ct` plugin from v0.2.0 to [v0.2.1](https://github.com/poseidon/terraform-provider-ct/releases/tag/v0.2.1) (action required!)
* Relax `os_image` to optional. Default to "coreos-stable".

#### Addons

* Update nginx-ingress from 0.11.0 to 0.12.0
* Update Prometheus from 2.2.0 to 2.2.1

## v1.9.4

* Kubernetes [v1.9.4](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.9.md#v194)
  * Secret, configMap, downward API, and projected volumes now read-only (breaking, [kubernetes#58720](https://github.com/kubernetes/kubernetes/pull/58720))
  * Regressed `subPath` volume mounts (regression, [kubernetes#61076](https://github.com/kubernetes/kubernetes/issues/61076))
  * Mitigated `subPath` [CVE-2017-1002101](https://github.com/kubernetes/kubernetes/issues/60813)
* Introduce [worker pools](https://typhoon.psdn.io/advanced/worker-pools/) for AWS and Google Cloud for joining heterogeneous workers to existing clusters.
* Use new Network Load Balancers and cross zone load balancing on AWS
* Allow flexvolume plugins to be used on any Typhoon cluster (not just bare-metal)
* Upgrade etcd from v3.2.15 to v3.3.2
* Update Calico from v3.0.2 to v3.0.3
* Use kubernetes-incubator/bootkube v0.11.0
* [Recommend](https://typhoon.psdn.io/topics/maintenance/#terraform-provider-ct-v021) updating `terraform-provider-ct` plugin from v0.2.0 to [v0.2.1](https://github.com/poseidon/terraform-provider-ct/releases/tag/v0.2.1) (action recommended)

#### AWS

* Promote AWS platform to stable
* Allow groups of workers to be defined and joined to a cluster (i.e. worker pools) ([#150](https://github.com/poseidon/typhoon/pull/150))
* Replace the apiserver elastic load balancer with a network load balancer ([#136](https://github.com/poseidon/typhoon/pull/136))
* Replace the Ingress elastic load balancer with a network load balancer ([#141](https://github.com/poseidon/typhoon/pull/141))
  * AWS [NLBs](https://aws.amazon.com/blogs/aws/new-network-load-balancer-effortless-scaling-to-millions-of-requests-per-second/) can handle millions of RPS with high throughput and low latency.
  * Require `terraform-provider-aws` 1.7.0 or higher
* Enable NLB [cross-zone](https://aws.amazon.com/about-aws/whats-new/2018/02/network-load-balancer-now-supports-cross-zone-load-balancing/) load balancing ([#159](https://github.com/poseidon/typhoon/pull/159))
  * Requests are automatically evenly distributed to targets regardless of AZ
  * Require `terraform-provider-aws` 1.11.0 or higher
* Add kubelet `--volume-plugin-dir` flag to allow flexvolume plugins ([#142](https://github.com/poseidon/typhoon/pull/142))
* Fix controller and worker launch configs to ignore AMI changes ([#126](https://github.com/poseidon/typhoon/pull/126), [#158](https://github.com/poseidon/typhoon/pull/158))

#### Digital Ocean

* Add kubelet `--volume-plugin-dir` flag to allow flexvolume plugins ([#142](https://github.com/poseidon/typhoon/pull/142))
* Fix to pass `ssh_fingerprints` as a list to droplets ([#143](https://github.com/poseidon/typhoon/pull/143))

#### Google Cloud

* Allow groups of workers to be defined and joined to a cluster (i.e. worker pools) ([#148](https://github.com/poseidon/typhoon/pull/148))
* Add kubelet `--volume-plugin-dir` flag to allow flexvolume plugins ([#142](https://github.com/poseidon/typhoon/pull/142))
* Add `kubeconfig` variable to `controllers` and `workers` submodules ([#147](https://github.com/poseidon/typhoon/pull/147))
* Remove `kubeconfig_*` variables from `controllers` and `workers` submodules ([#147](https://github.com/poseidon/typhoon/pull/147))
* Allow initial experimentation with accelerators (i.e. GPUs) on workers ([#161](https://github.com/poseidon/typhoon/pull/161)) (unofficial)
  * Require `terraform-provider-google` v1.6.0

#### Addons

* Update Prometheus from 2.1.0 to 2.2.0 ([#153](https://github.com/poseidon/typhoon/pull/153))
  * Scrape Prometheus itself to enable alerts about Prometheus itself
  * Adjust KubeletDown rule to fire when 10% of kubelets are down
* Update heapster from v1.5.0 to v1.5.1 ([#131](https://github.com/poseidon/typhoon/pull/131))
  * Use separate service account
* Update nginx-ingress from 0.10.2 to 0.11.0

## v1.9.3

* Kubernetes [v1.9.3](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.9.md#v193)
* Network improvements and fixes ([#104](https://github.com/poseidon/typhoon/pull/104))
  * Switch from Calico v2.6.6 to v3.0.2
  * Add Calico GlobalNetworkSet CRD
  * Update flannel from v0.9.0 to v0.10.0
  * Use separate service account for flannel
* Update etcd from v3.2.14 to v3.2.15

#### Digital Ocean

* Use new Droplet [types](https://developers.digitalocean.com/documentation/changelog/api-v2/new-size-slugs-for-droplet-plan-changes/) which offer more CPU/memory, at lower cost. ([#105](https://github.com/poseidon/typhoon/pull/105))
  * A small Digital Ocean cluster costs less than $25 a month!

#### Addons

* Update Prometheus from v2.0.0 to v2.1.0 ([#113](https://github.com/poseidon/typhoon/pull/113))
  * Improve alerting rules
  * Relabel discovered kubelet, endpoint, service, and apiserver scrapes
  * Use separate service accounts
  * Update node-exporter and kube-state-metrics
* Include Grafana dashboards for Kubernetes admins ([#113](https://github.com/poseidon/typhoon/pull/113))
  * Add grafana-watcher to load bundled upstream dashboards
* Update nginx-ingress from 0.9.0 to 0.10.2
* Update CLUO from v0.5.0 to v0.6.0
* Switch manifests to use `apps/v1` Deployments and Daemonsets ([#120](https://github.com/poseidon/typhoon/pull/120))
* Remove Kubernetes Dashboard manifests ([#121](https://github.com/poseidon/typhoon/pull/121))

## v1.9.2

* Kubernetes [v1.9.2](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.9.md#v192)
* Add Terraform v0.11.x support
  * Add explicit "providers" section to modules for Terraform v0.11.x
  * Retain support for Terraform v0.10.4+
* Add [migration guide](https://typhoon.psdn.io/topics/maintenance/#terraform-v011x) from Terraform v0.10.x to v0.11.x (**action required!**)
* Update etcd from 3.2.13 to 3.2.14
* Update calico from 2.6.5 to 2.6.6
* Update kube-dns from v1.14.7 to v1.14.8
* Use separate service account for kube-dns
* Use kubernetes-incubator/bootkube v0.10.0

#### Bare-Metal

* Use per-node Container Linux install profiles ([#97](https://github.com/poseidon/typhoon/pull/97))
  * Allow Container Linux channel/version to be chosen per-cluster
  * Fix issue where cluster deletion could require `terraform apply` multiple times

#### Digital Ocean

* Relax `digitalocean` provider version constraint
* Fix bug with `terraform plan` always showing a firewall diff to be applied ([#3](https://github.com/poseidon/typhoon/issues/3))

#### Addons

* Update CLUO to v0.5.0 to fix compatibility with Kubernetes 1.9 (**important**)
  * Earlier versions can't roll out Container Linux updates on Kubernetes 1.9 nodes ([cluo#163](https://github.com/coreos/container-linux-update-operator/issues/163))
* Update kube-state-metrics from v1.1.0 to v1.2.0
* Fix RBAC cluster role for kube-state-metrics

## v1.9.1

* Kubernetes [v1.9.1](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.9.md#v191)
* Update kube-dns from 1.14.5 to v1.14.7
* Update etcd from 3.2.0 to 3.2.13
* Update Calico from v2.6.4 to v2.6.5
* Enable portmap to fix hostPort with Calico
* Use separate service account for controller-manager

## v1.8.6

* Kubernetes [v1.8.6](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.8.md#v186)
* Update Calico from v2.6.3 to v2.6.4

## v1.8.5

* Kubernetes [v1.8.5](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.8.md#v185)
* Recommend Container Linux [images](https://coreos.com/releases/) with Docker 17.09
  * Container Linux stable, beta, and alpha now provide Docker 17.09 (instead
  of 1.12)
  * Older clusters (with CLUO addon) auto-update Container Linux version to begin using Docker 17.09
* Fix race where `etcd-member.service` could fail to resolve peers ([#69](https://github.com/poseidon/typhoon/pull/69))
* Add optional `cluster_domain_suffix` variable (#74)
* Use kubernetes-incubator/bootkube v0.9.1

#### Bare-Metal

* Add kubelet `--volume-plugin-dir` flag to allow flexvolume providers ([#61](https://github.com/poseidon/typhoon/pull/61))

#### Addons

* Discourage deploying the Kubernetes Dashboard (security)

## v1.8.4

* Kubernetes v1.8.4
* Calico related bug fixes
* Update Calico from v2.6.1 to v2.6.3
* Update flannel from v0.9.0 to v0.9.1
* Service accounts for kube-proxy and pod-checkpointer
* Use kubernetes-incubator/bootkube v0.9.0

## v1.8.3

* Kubernetes v1.8.3
* Run etcd on-host, across controllers
* Promote AWS platform to beta
* Use kubernetes-incubator/bootkube v0.8.2

#### Google Cloud

* Add required variable `region` (e.g. "us-central1")
* Reduce time to bootstrap a cluster
* Change etcd to run on-host, across controllers (etcd-member.service)
* Change controller instances to automatically span zones in the region
* Change worker managed instance group to automatically span zones in the region
* Improve internal firewall rules and use tag-based firewall policies
* Remove support for self-hosted etcd
* Remove the `zone` required variable
* Remove the `controller_preemptible` optional variable

#### AWS

* Promote AWS platform to beta
* Reduce time to bootstrap a cluster
* Change etcd to run on-host, across controllers (etcd-member.service)
* Fix firewall rules for multi-controller kubelet scraping and node-exporter
* Remove support for self-hosted etcd

#### Addons

* Add Prometheus 2.0 addon with alerting rules
* Add Grafana dashboard for observing metrics

## v1.8.2

* Kubernetes v1.8.2
  * Fixes a memory leak in the v1.8.1 apiserver ([kubernetes#53485](https://github.com/kubernetes/kubernetes/issues/53485))
* Switch to using the `gcr.io/google_containers/hyperkube`
* Update flannel from v0.8.0 to v0.9.0
* Add `hairpinMode` to flannel CNI config
* Add `--no-negcache` to kube-dns dnsmasq
* Use kubernetes-incubator/bootkube v0.8.1

## v1.8.1

* Kubernetes v1.8.1
* Use kubernetes-incubator/bootkube v0.8.0

#### Digital Ocean

* Run etcd cluster across controller nodes (etcd-member.service)
* Remove support for self-hosted etcd
* Reduce time to bootstrap a cluster

## v1.7.7

* Kubernetes v1.7.7
* Use kubernetes-incubator/bootkube v0.7.0
* Update kube-dns to 1.14.5 to fix dnsmasq [vulnerability](https://security.googleblog.com/2017/10/behind-masq-yet-more-dns-and-dhcp.html)
* Calico v2.6.1
* flannel-cni v0.3.0
  * Update flannel CNI config to fix hostPort

## v1.7.5

* Kubernetes v1.7.5
* Use kubernetes-incubator/bootkube v0.6.2
* Add AWS Terraform module (alpha)
* Add support for Calico networking (bare-metal, Google Cloud, AWS)
* Change networking default from "flannel" to "calico"

#### AWS

* Add `network_mtu` to allow CNI interface MTU customization

#### Bare-Metal

* Add `network_mtu` to allow CNI interface MTU customization
* Remove support for `experimental_self_hosted_etcd`

## v1.7.3

* Kubernetes v1.7.3
* Use kubernetes-incubator/bootkube v0.6.1

#### Digital Ocean

* Add cloud firewall rules (requires Terraform v0.10)
* Change nodes tags from strings to DO tags

## v1.7.1

* Kubernetes v1.7.1
* Use kubernetes-incubator/bootkube v0.6.0
* Add Bare-Metal Terraform module (stable)
* Add Digital Ocean Terraform module (beta)

#### Google Cloud

* Remove `k8s_domain_name` variable, `cluster_name` + `dns_zone` resolves to controllers
* Rename `dns_base_zone` to `dns_zone`
* Rename `dns_base_zone_name` to `dns_zone_name`

## v1.6.7

* Kubernetes v1.6.7
* Use kubernetes-incubator/bootkube v0.5.1

## v1.6.6

* Kubernetes v1.6.6
* Use kubernetes-incubator/bootkube v0.4.5
* Disable locksmithd on hosts, in favor of [CLUO](https://github.com/coreos/container-linux-update-operator).

## v1.6.4

* Kubernetes v1.6.4
* Add Google Cloud Terraform module (stable)

## Earlier

Earlier versions, back to v1.3.0, used different designs and mechanisms.
