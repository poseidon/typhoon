# Maintenance

## Best Practices

* Run multiple Kubernetes clusters. Run across platforms. Plan for regional and cloud outages.
* Require applications be platform agnostic. Moving an application between a Kubernetes AWS cluster and a Kubernetes bare-metal cluster should be normal.
* Strive to make single-cluster outages tolerable. Practice performing failovers.
* Strive to make single-cluster outages a non-event. Load balance applications between multiple clusters, automate failover behaviors, and adjust alerting behaviors.

## Versioning

Typhoon provides tagged releases to allow clusters to be versioned using ordinary Terraform configs.

```
module "yavin" {
  source = "git::https://github.com/poseidon/typhoon//google-cloud/fedora-coreos/kubernetes?ref=v1.27.2"
  ...
}

module "mercury" {
  source = "git::https://github.com/poseidon/typhoon//bare-metal/flatcar-linux/kubernetes?ref=v1.27.2"
  ...
}
```

Main is updated regularly, so it is recommended to [pin](https://www.terraform.io/docs/modules/sources.html) modules to a [release tag](https://github.com/poseidon/typhoon/releases) or [commit](https://github.com/poseidon/typhoon/commits/main) hash. Pinning ensures `terraform get --update` only fetches the desired version.

## Terraform Versions

Typhoon modules support Terraform v0.13.x and higher. Poseidon publishes [providers](/topics/security/#terraform-providers) to the Terraform Provider Registry for automatic install via `terraform init`.

| Typhoon Release   | Terraform version   |
|-------------------|---------------------|
| v1.21.2 - ?       | v0.13.x, v0.14.4+, v0.15.x, v1.0.x |
| v1.21.1 - v1.21.1 | v0.13.x, v0.14.4+, v0.15.x |
| v1.20.2 - v1.21.0 | v0.13.x, v0.14.4+   |
| v1.20.0 - v1.20.2 | v0.13.x             |
| v1.18.8 - v1.19.4 | v0.12.26+, v0.13.x  |
| v1.15.0 - v1.18.8 | v0.12.x             |
| v1.10.3 - v1.15.0 | v0.11.x             |
| v1.9.2 - v1.10.2  | v0.10.4+ or v0.11.x |
| v1.7.3 - v1.9.1   | v0.10.x             |
| v1.6.4 - v1.7.2   | v0.9.x              |


## Cluster Upgrades

Typhoon recommends upgrading clusters using a blue-green replacement strategy and migrating workloads.

1. Launch new (candidate) clusters from tagged releases
2. Apply workloads from existing cluster(s)
3. Evaluate application health and performance
4. Migrate application traffic to the new cluster
5. Compare metrics and delete old cluster when ready

Blue-green replacement reduces risk for clusters running critical applications. Candidate clusters allow baseline properties of clusters to be assessed (e.g. pod-to-pod bandwidth). Applying application workloads allows health to be assessed before being subjected to traffic (e.g. detect any changes in Kubernetes behavior between versions). Migration to the new cluster can be controlled according to requirements. Migration may mean updating DNS records to resolve the new cluster's ingress or may involve a load balancer gradually shifting traffic to the new cluster "backend". Retain the old cluster for a time to compare metrics or for fallback if issues arise.

Blue-green replacement provides some subtler benefits as well:

* Encourages investment in tooling for traffic migration and failovers. When a cluster incident arises, shifting applications to a healthy cluster will be second nature.
* Discourages reliance on in-place opaque state. Retain confidence in your ability to create infrastructure from scratch.
* Allows Typhoon to make architecture changes between releases and eases the burden on Typhoon maintainers. By contrast, distros promising in-place upgrades get stuck with their mistakes or require complex and error-prone migrations.

### Bare-Metal

Typhoon bare-metal clusters are provisioned by a PXE-enabled network boot environment and a [Matchbox](https://github.com/poseidon/matchbox) service. To upgrade, re-provision machines into a new cluster.

Failover application workloads to another cluster (varies).

```
kubectl config use-context other-context
kubectl apply -f mercury -R
# DNS or load balancer changes
```

Power off bare-metal machines and set their next boot device to PXE.

```
ipmitool -H node1.example.com -U USER -P PASS power off
ipmitool -H node1.example.com -U USER -P PASS chassis bootdev pxe
```

Delete or comment the Terraform config for the cluster.

```
- module "mercury" {
-   source = "git::https://github.com/poseidon/typhoon//bare-metal/flatcar-linux/kubernetes"
-   ...
-}
```

Apply to delete old provisioning configs from Matchbox.

```
$ terraform apply
Apply complete! Resources: 0 added, 0 changed, 55 destroyed.
```

Re-provision a new cluster by following the bare-metal [tutorial](../fedora-coreos/bare-metal.md#cluster).

### Cloud

Create a new cluster following the tutorials. Failover application workloads to the new cluster (varies).

```
kubectl config use-context other-context
kubectl apply -f mercury -R
# DNS or load balancer changes
```

Once you're confident in the new cluster, delete the Terraform config for the old cluster.

```
- module "yavin" {
-   source = "git::https://github.com/poseidon/typhoon//google-cloud/flatcar-linux/kubernetes"
-   ...
-}
```

Apply to delete the cluster.

```
$ terraform apply
Apply complete! Resources: 0 added, 0 changed, 55 destroyed.
```

### Alternatives

#### In-place Edits

Typhoon uses a static pod Kubernetes control plane which allows certain manifest upgrades to be performed in-place. Components like `kube-apiserver`, `kube-controller-manager`, and `kube-scheduler` are run as static pods. Components `flannel`/`calico`, `coredns`, and `kube-proxy` are scheduled on Kubernetes and can be edited via `kubectl`.

In certain scenarios, in-place edits can be useful for quickly rolling out security patches (e.g. bumping `coredns`) or prioritizing speed over the safety of a proper cluster re-provision and transition.

!!! note
    Rarely, we may test certain security in-place edits and mention them as an option in release notes.

!!! warning
    Typhoon does not support or document in-place edits as an upgrade strategy. They involve inherent risks and we choose not to make recommendations or guarentees about the safety of different in-place upgrades. Its explicitly a non-goal.

#### Node Replacement

Typhoon supports multi-controller clusters, so it is possible to upgrade a cluster by deleting and replacing nodes one by one.

!!! warning
    Typhoon does not support or document node replacement as an upgrade strategy. It limits Typhoon's ability to make infrastructure and architectural changes between tagged releases.

## Node Configuration Updates

Typhoon worker instance groups (default workers and [worker pools](../advanced/worker-pools.md)) on AWS and Google Cloud gradually rolling replace worker instances when configuration changes are applied.

### AWS

On AWS, worker instances belong to an auto-scaling group. When an auto-scaling group's launch configuration changes, an AWS [Instance Refresh](https://docs.aws.amazon.com/autoscaling/ec2/userguide/asg-instance-refresh.html) gradually replaces worker instances.

Instance refresh creates surge instances, waits for a warm-up period, then deletes old instances.

```diff
module "tempest" {
  source = "git::https://github.com/poseidon/typhoon//aws/VARIANT/kubernetes?ref=VERSION"

  # AWS
  cluster_name = "tempest"
  ...

  # optional
  worker_count = 2
- worker_type  = "t3.small"
+ worker_type  = "t3a.small"

  # change from on-demand to spot
+ worker_price = "0.0309"

  # default is 30GB
+ disk_size = 50

  # change worker snippets
+ worker_snippets = [
+   file("butane/feature.yaml"),
+ ]
}
```

Applying edits to most worker fields will start an instance refresh:

* `worker_type`
* `disk_*`
* `worker_price` (i.e. spot)
* `worker_target_groups`
* `worker_snippets`

However, changing `os_stream`/`os_channel` or new AMIs becoming available will NOT change the launch configuration or trigger an Instance Refresh. This allows Fedora CoreOS or Flatcar Linux to auto-update themselves via reboots and avoids unexpected terraform diffs for new AMIs.

!!! note
    Before Typhoon v1.27.2, worker nodes only used new launch configurations when replaced manually (or due to failure). If you must change node configuration manually, it's still possible. Create a new [worker pool](../advanced/worker-pools.md), then scale down the old worker pool as desired.

### Google Cloud

On Google Cloud, worker instances belong to a [managed instance group](https://cloud.google.com/compute/docs/instance-groups#managed_instance_groups). When a group's launch template changes, a [rolling update](https://cloud.google.com/compute/docs/instance-groups/rolling-out-updates-to-managed-instance-groups) gradually replaces worker instances.

The rolling update creates surge instances, waits for instances to be healthy, then deletes old instances.

```diff
module "yavin" {
  source = "git::https://github.com/poseidon/typhoon//google-cloud/VARIANT/kubernetes?ref=VERSION"

  # Google Cloud
  cluster_name  = "yavin"
  ...

  # optional
  worker_count = 2
+ worker_type = "n2-standard-2"
+ worker_preemptible = true

  # default is 30GB
+ disk_size = 50

  # change worker snippets
+ worker_snippets = [
+   file("butane/feature.yaml"),
+ ]
}
```

Applying edits to most worker fields will start an instance refresh:

* `worker_type`
* `disk_*`
* `worker_preemptible` (i.e. spot)
* `worker_snippets`

However, changing `os_stream`/`os_channel` or new compute images becoming available will NOT change the launch template or update instances. This allows Fedora CoreOS or Flatcar Linux to auto-update themselves via reboots and avoids unexpected terraform diffs for new AMIs.

!!! note
    Before Typhoon v1.27.2, worker nodes only used new launch templates when replaced manually (or due to failure). If you must change node configuration manually, it's still possible. Create a new [worker pool](../advanced/worker-pools.md), then scale down the old worker pool as desired.

## Upgrade poseidon/ct

The [poseidon/ct](https://github.com/poseidon/terraform-provider-ct) Terraform provider plugin parses, validates, and converts Butane Configs to Ignition user-data for provisioning instances. Since Typhoon v1.12.2+, the plugin can be updated in-place so that on apply, only workers will be replaced.

Update the version of the `ct` plugin in each Terraform working directory. Typhoon clusters managed in the working directory **must** be v1.12.2 or higher.

```diff
provider "ct" {}

terraform {
  required_providers {
    ct = {
      source  = "poseidon/ct"
-     version = "0.10.0"
+     version = "0.11.0"
    }
    ...
  }
}
```

Run init and plan to check that no diff is proposed for the controller nodes (a diff would destroy cluster state).

```
terraform init
terraform plan
```

Apply the change. If worker nodes' user-data is changed and workers will be replaced. Rollout happens slightly differently on each platform:

#### AWS

See AWS node [config updates](#aws).

#### Azure

Azure edits the worker scale set in-place instantly. Manually terminate workers to create replacement workers using the new user-data.

#### Bare-Metal

No action is needed. Bare-Metal machines do not re-PXE unless explicitly made to do so.

#### DigitalOcean

DigitalOcean destroys existing worker nodes and DNS records, then creates new workers and DNS records. DigitalOcean lacks a "managed group" notion. For worker droplets to join the cluster, you **must** taint the secret copying step to indicate it must be repeated to add the kubeconfig to new workers.

```
# old workers destroyed, new workers created
terraform apply

# add kubeconfig to new workers
terraform state list | grep null_resource
terraform taint module.nemo.null_resource.copy-worker-secrets[N]
terraform apply
```

Expect downtime.

#### Google Cloud

See Google Cloud node [config updates](#google-cloud).
