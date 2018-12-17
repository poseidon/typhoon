# Maintenance

## Best Practices

* Run multiple Kubernetes clusters. Run across platforms. Plan for regional and cloud outages.
* Require applications be platform agnostic. Moving an application between a Kubernetes AWS cluster and a Kubernetes bare-metal cluster should be normal.
* Strive to make single-cluster outages tolerable. Practice performing failovers.
* Strive to make single-cluster outages a non-event. Load balance applications between multiple clusters, automate failover behaviors, and adjust alerting behaviors.

## Versioning

Typhoon provides tagged releases to allow clusters to be versioned using ordinary Terraform configs.

```
module "google-cloud-yavin" {
  source = "git::https://github.com/poseidon/typhoon//google-cloud/container-linux/kubernetes?ref=v1.8.6"
  ...
}

module "bare-metal-mercury" {
  source = "git::https://github.com/poseidon/typhoon//bare-metal/container-linux/kubernetes?ref=v1.13.1"
  ...
}
```

Master is updated regularly, so it is recommended to [pin](https://www.terraform.io/docs/modules/sources.html) modules to a [release tag](https://github.com/poseidon/typhoon/releases) or [commit](https://github.com/poseidon/typhoon/commits/master) hash. Pinning ensures `terraform get --update` only fetches the desired version.

## Upgrades

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

Typhoon bare-metal clusters are provisioned by a PXE-enabled network boot environment and a [Matchbox](https://github.com/coreos/matchbox) service. To upgrade, re-provision machines into a new cluster.

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
- module "bare-metal-mercury" {
-   source = "git::https://github.com/poseidon/typhoon//bare-metal/container-linux/kubernetes"
-   ...
-}
```

Apply to delete old provisioning configs from Matchbox.

```
$ terraform apply  
Apply complete! Resources: 0 added, 0 changed, 55 destroyed.
```

Re-provision a new cluster by following the bare-metal [tutorial](../cl/bare-metal.md#cluster).

### Cloud

Create a new cluster following the tutorials. Failover application workloads to the new cluster (varies).

```
kubectl config use-context other-context
kubectl apply -f mercury -R
# DNS or load balancer changes
```

Once you're confident in the new cluster, delete the Terraform config for the old cluster.

```
- module "google-cloud-yavin" {
-   source = "git::https://github.com/poseidon/typhoon//google-cloud/container-linux/kubernetes"
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

Typhoon uses a self-hosted Kubernetes control plane which allows certain manifest upgrades to be performed in-place. Components like `apiserver`, `controller-manager`, `scheduler`, `flannel`/`calico`, `coredns`, and `kube-proxy` are run on Kubernetes itself and can be edited via `kubectl`. If you're interested, see the bootkube [upgrade docs](https://github.com/kubernetes-incubator/bootkube/blob/master/Documentation/upgrading.md).

In certain scenarios, in-place edits can be useful for quickly rolling out security patches (e.g. bumping `coredns`) or prioritizing speed over the safety of a proper cluster re-provision and transition.

!!! note
    Rarely, we may test certain security in-place edits and mention them as an option in release notes.

!!! warning
    Typhoon does not support or document in-place edits as an upgrade strategy. They involve inherent risks and we choose not to make recommendations or guarentees about the safety of different in-place upgrades. Its explicitly a non-goal.

#### Node Replacement

Typhoon supports multi-controller clusters, so it is possible to upgrade a cluster by deleting and replacing nodes one by one.

!!! warning
    Typhoon does not support or document node replacement as an upgrade strategy. It limits Typhoon's ability to make infrastructure and architectural changes between tagged releases. 

### Terraform Plugins Directory

Use the Terraform 3rd-party [plugin directory](https://www.terraform.io/docs/configuration/providers.html#third-party-plugins) `~/.terraform.d/plugins` to keep versioned copies of the `terraform-provider-ct` and `terraform-provider-matchbox` plugins. The plugin directory replaces the `~/.terraformrc` file to allow 3rd party plugins to be defined and versioned independently (rather than globally).

```
# ~/.terraformrc (DEPRECATED)
providers {
  ct = "/usr/local/bin/terraform-provider-ct"
  matchbox = "/usr/local/bin/terraform-provider-matchbox"
}
```

Migrate to using the Terraform plugin directory. Move `~/.terraformrc` to a backup location.

```
mv ~/.terraformrc ~/.terraform-backup
```

Add the [terraform-provider-ct](https://github.com/coreos/terraform-provider-ct) plugin binary for your system to `~/.terraform.d/plugins/`. Download the **same version** of `terraform-provider-ct` you were using with `~/.terraformrc`, updating only be done as a followup and is **only** safe for v1.12.2+ clusters!

```sh
wget https://github.com/coreos/terraform-provider-ct/releases/download/v0.2.1/terraform-provider-ct-v0.2.1-linux-amd64.tar.gz
tar xzf terraform-provider-ct-v0.2.1-linux-amd64.tar.gz
mv terraform-provider-ct-v0.2.1-linux-amd64/terraform-provider-ct ~/.terraform.d/plugins/terraform-provider-ct_v0.2.1
```

If you use bare-metal, add the [terraform-provider-matchbox](https://github.com/coreos/terraform-provider-matchbox) plugin binary for your system to `~/.terraform.d/plugins/`, noting the versioned name.

```sh
wget https://github.com/coreos/terraform-provider-matchbox/releases/download/v0.2.2/terraform-provider-matchbox-v0.2.2-linux-amd64.tar.gz
tar xzf terraform-provider-matchbox-v0.2.2-linux-amd64.tar.gz
mv terraform-provider-matchbox-v0.2.2-linux-amd64/terraform-provider-matchbox ~/.terraform.d/plugins/terraform-provider-matchbox_v0.2.2
```

Binary names are versioned. This enables the ability to upgrade different plugins and have clusters pin different versions.

```
$ tree ~/.terraform.d/
/home/user/.terraform.d/
└── plugins
    ├── terraform-provider-ct_v0.2.1
    └── terraform-provider-matchbox_v0.2.2
```

In each Terraform working directory, set the version of each provider.

```
# providers.tf

provider "matchbox" {
  version = "0.2.2"
  ...
}

provider "ct" {
  version = "0.2.1"
}
```

Run `terraform init` to ensure plugin version requirements are met. Verify `terraform plan` does not produce a diff, since the plugin versions should be the same as previously.

```
$ terraform init
$ terraform plan
```

### Upgrade terraform-provider-ct

The [terraform-provider-ct](https://github.com/coreos/terraform-provider-ct) plugin parses, validates, and converts Container Linux Configs into Ignition user-data for provisioning instances. Previously, updating the plugin re-provisioned controller nodes and was destructive to clusters. With Typhoon v1.12.2+, the plugin can be updated in-place and on apply, only workers will be replaced.

First, [migrate](#terraform-plugins-directory) to the Terraform 3rd-party plugin directory to allow 3rd-party plugins to be defined and versioned independently (rather than globally).

Add the [terraform-provider-ct](https://github.com/coreos/terraform-provider-ct) plugin binary for your system to `~/.terraform.d/plugins/`, noting the final name.

```sh
wget https://github.com/coreos/terraform-provider-ct/releases/download/v0.3.0/terraform-provider-ct-v0.3.0-linux-amd64.tar.gz
tar xzf terraform-provider-ct-v0.3.0-linux-amd64.tar.gz
mv terraform-provider-ct-v0.3.0-linux-amd64/terraform-provider-ct ~/.terraform.d/plugins/terraform-provider-ct_v0.3.0
```

Binary names are versioned. This enables the ability to upgrade different plugins and have clusters pin different versions.

```
$ tree ~/.terraform.d/
/home/user/.terraform.d/
└── plugins
    ├── terraform-provider-ct_v0.2.1
    ├── terraform-provider-ct_v0.3.0
    └── terraform-provider-matchbox_v0.2.2
```


Update the version of the `ct` plugin in each Terraform working directory. Typhoon clusters managed in the working directory **must** be v1.12.2 or higher.

```
# providers.tf
provider "ct" {
  version = "0.3.0"
}
```

Run init and plan to check that no diff is proposed for the controller nodes (a diff would destroy cluster state).

```
terraform init
terraform plan
```

Apply the change. Worker nodes' user-data will be changed and workers will be replaced. Rollout happens slightly differently on each platform:


#### AWS

AWS creates a new worker ASG, then removes the old ASG. New workers join the cluster and old workers disappear. `terraform apply` will hang during this process.

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
terraform taint -module digital-ocean-nemo null_resource.copy-worker-secrets.N
terraform apply
```

Expect downtime.

#### Google Cloud

Google Cloud creates a new worker template and edits the worker instance group instantly. Manually terminate workers and replacement workers will use the user-data.

