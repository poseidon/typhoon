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
  source = "git::https://github.com/poseidon/typhoon//google-cloud/fedora-coreos/kubernetes?ref=v1.21.2"
  ...
}

module "mercury" {
  source = "git::https://github.com/poseidon/typhoon//bare-metal/flatcar-linux/kubernetes?ref=v1.21.2"
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

### Upgrade terraform-provider-ct

The [terraform-provider-ct](https://github.com/poseidon/terraform-provider-ct) plugin parses, validates, and converts Fedora CoreOS or Flatcar Linux Configs into Ignition user-data for provisioning instances. Since Typhoon v1.12.2+, the plugin can be updated in-place so that on apply, only workers will be replaced.

Update the version of the `ct` plugin in each Terraform working directory. Typhoon clusters managed in the working directory **must** be v1.12.2 or higher.

```diff
provider "ct" {}

terraform {
  required_providers {
    ct = {
      source  = "poseidon/ct"
-     version = "0.7.1"
+     version = "0.8.0"
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
terraform taint module.nemo.null_resource.copy-worker-secrets[N]
terraform apply
```

Expect downtime.

#### Google Cloud

Google Cloud creates a new worker template and edits the worker instance group instantly. Manually terminate workers and replacement workers will use the user-data.

## Terraform Versions

Terraform [v0.13](https://www.hashicorp.com/blog/announcing-hashicorp-terraform-0-13) introduced major changes to the provider plugin system. Terraform `init` can automatically install both `hashicorp` and `poseidon` provider plugins, eliminating the need to manually install plugin binaries.

Typhoon modules have been updated for v0.13.x. Poseidon publishes [providers](/topics/security/#terraform-providers) to the Terraform Provider Registry for usage with v0.13+.

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

### New Workspace

With a new Terraform workspace, use Terraform v0.15.x and the updated Typhoon [tutorials](/fedora-coreos/aws/#provider).

### Existing Workspace

An existing Terraform workspace may already manage earlier Typhoon clusters created with Terraform v0.12.x.

First, upgrade `terraform-provider-ct` to v0.6.1 following the [guide](#upgrade-terraform-provider-ct) above. As usual, read about how `apply` affects existing cluster nodes when `ct` is upgraded. But `terraform-provider-ct` v0.6.1 is compatible with both Terraform v0.12 and v0.13, so do this first.

```tf
provider "ct" {
  version = "0.6.1"
}
```

Next, create Typhoon clusters using the `ref` that introduced Terraform v0.13 forward compatibility (`v1.18.8`) or later. You will see a compatibility warning. Use blue/green cluster replacement to shift to these new clusters, then eliminate older clusters.

```
module "nemo" {
  source = "git::https://github.com/poseidon/typhoon//digital-ocean/fedora-coreos/kubernetes?ref=v1.18.8"
  ...
}
```

Install Terraform v0.13. Once all clusters in a workspace are on `v1.18.8` or above, you are ready to start using Terraform v0.13.

```
terraform version
v0.13.0
```

Update `providers.tf` to match the Typhoon [tutorials](/fedora-coreos/aws/#provider) and use new `required_providers` block.

```
terraform init
terraform 0.13upgrade    # sometimes helpful
```

!!! note
    You will see `Could not retrieve the list of available versions for provider -/ct: provider`

In state files, existing clusters use Terraform v0.12 providers (e.g. `-/aws`). Pivot to Terraform v0.13 providers (e.g. `hashicorp/aws`) with the following commands, as applicable. Repeat until `terraform init` no longer shows old-style providers.

```
terraform state replace-provider -- -/aws hashicorp/aws
terraform state replace-provider -- -/azurerm hashicorp/azurerm
terraform state replace-provider -- -/google hashicorp/google

terraform state replace-provider -- -/digitalocean digitalocean/digitalocean
terraform state replace-provider -- -/ct poseidon/ct
terraform state replace-provider -- -/matchbox poseidon/matchbox

terraform state replace-provider -- -/local hashicorp/local
terraform state replace-provider -- -/null hashicorp/null
terraform state replace-provider -- -/random hashicorp/random
terraform state replace-provider -- -/template hashicorp/template
terraform state replace-provider -- -/tls hashicorp/tls
```

Finally, verify Terraform v0.13 plan shows no diff.

```
terraform plan
No changes. Infrastructure is up-to-date.
```

### v0.12.x

Terraform [v0.12](https://www.hashicorp.com/blog/announcing-terraform-0-12) introduced major changes to the provider plugin protocol and HCL language (first-class expressions, formal list and map types, nullable variables, variable constraints, and short-circuiting ternary operators).

Typhoon modules have been adapted for Terraform v0.12. Provider plugins requirements now enforce v0.12 compatibility. However, some HCL language changes were breaking (list [type hint](https://www.terraform.io/upgrade-guides/0-12.html#referring-to-list-variables) workarounds in v0.11 now have new meaning). Typhoon cannot offer both v0.11 and v0.12 compatibility in the same release. Upcoming releases require upgrading Terraform to v0.12.

