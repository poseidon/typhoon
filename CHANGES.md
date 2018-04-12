# Typhoon

Notable changes between versions.

## Latest

* Enable etcd v3.3 metrics endpoint ([#175](https://github.com/poseidon/typhoon/pull/175))
* Use `k8s.gcr.io` instead of `gcr.io/google_containers` ([#180](https://github.com/poseidon/typhoon/pull/180))
  * Kubernetes [recommends](https://groups.google.com/forum/#!msg/kubernetes-dev/ytjk_rNrTa0/3EFUHvovCAAJ) using the alias to pull from the nearest regional mirror and to abstract the backing container registry
* Update kube-dns from v1.14.8 to v1.14.9
* Update etcd from v3.3.2 to v3.3.3

#### Bare-Metal

* Fix need for multiple `terraform apply` runs to create a cluster with Terraform v0.11.4 ([#181](https://github.com/poseidon/typhoon/pull/181))
  * To SSH during a disk install for debugging, SSH as user "core" with port 2222
  * Remove the old trick of using a user "debug" during disk install

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

* [Require](https://typhoon.psdn.io/topics/maintenance/#terraform-provider-ct-v021) updating `terraform-provider-ct` plugin from v0.2.0 to [v0.2.1](https://github.com/coreos/terraform-provider-ct/releases/tag/v0.2.1) (action required!)

#### Digital Ocean

* [Require](https://typhoon.psdn.io/topics/maintenance/#terraform-provider-ct-v021) updating `terraform-provider-ct` plugin from v0.2.0 to [v0.2.1](https://github.com/coreos/terraform-provider-ct/releases/tag/v0.2.1) (action required!)

#### Google Cloud

* [Require](https://typhoon.psdn.io/topics/maintenance/#terraform-provider-ct-v021) updating `terraform-provider-ct` plugin from v0.2.0 to [v0.2.1](https://github.com/coreos/terraform-provider-ct/releases/tag/v0.2.1) (action required!)
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
* Use kubernetes-incubator/bootkube v0.10.0
* [Recommend](https://typhoon.psdn.io/topics/maintenance/#terraform-provider-ct-v021) updating `terraform-provider-ct` plugin from v0.2.0 to [v0.2.1](https://github.com/coreos/terraform-provider-ct/releases/tag/v0.2.1) (action recommended)

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
