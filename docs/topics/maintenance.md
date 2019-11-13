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
  source = "git::https://github.com/poseidon/typhoon//bare-metal/container-linux/kubernetes?ref=v1.16.3"
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

Add the [terraform-provider-ct](https://github.com/poseidon/terraform-provider-ct) plugin binary for your system to `~/.terraform.d/plugins/`. Download the **same version** of `terraform-provider-ct` you were using with `~/.terraformrc`, updating only be done as a followup and is **only** safe for v1.12.2+ clusters!

```sh
wget https://github.com/poseidon/terraform-provider-ct/releases/download/v0.2.1/terraform-provider-ct-v0.2.1-linux-amd64.tar.gz
tar xzf terraform-provider-ct-v0.2.1-linux-amd64.tar.gz
mv terraform-provider-ct-v0.2.1-linux-amd64/terraform-provider-ct ~/.terraform.d/plugins/terraform-provider-ct_v0.2.1
```

If you use bare-metal, add the [terraform-provider-matchbox](https://github.com/poseidon/terraform-provider-matchbox) plugin binary for your system to `~/.terraform.d/plugins/`, noting the versioned name.

```sh
wget https://github.com/poseidon/terraform-provider-matchbox/releases/download/v0.2.3/terraform-provider-matchbox-v0.2.3-linux-amd64.tar.gz
tar xzf terraform-provider-matchbox-v0.2.3-linux-amd64.tar.gz
mv terraform-provider-matchbox-v0.2.3-linux-amd64/terraform-provider-matchbox ~/.terraform.d/plugins/terraform-provider-matchbox_v0.2.3
```

Binary names are versioned. This enables the ability to upgrade different plugins and have clusters pin different versions.

```
$ tree ~/.terraform.d/
/home/user/.terraform.d/
└── plugins
    ├── terraform-provider-ct_v0.2.1
    └── terraform-provider-matchbox_v0.2.3
```

In each Terraform working directory, set the version of each provider.

```
# providers.tf

provider "matchbox" {
  version = "0.2.3"
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

The [terraform-provider-ct](https://github.com/poseidon/terraform-provider-ct) plugin parses, validates, and converts Container Linux Configs into Ignition user-data for provisioning instances. Previously, updating the plugin re-provisioned controller nodes and was destructive to clusters. With Typhoon v1.12.2+, the plugin can be updated in-place and on apply, only workers will be replaced.

First, [migrate](#terraform-plugins-directory) to the Terraform 3rd-party plugin directory to allow 3rd-party plugins to be defined and versioned independently (rather than globally).

Add the [terraform-provider-ct](https://github.com/poseidon/terraform-provider-ct) plugin binary for your system to `~/.terraform.d/plugins/`, noting the final name.

```sh
wget https://github.com/poseidon/terraform-provider-ct/releases/download/v0.3.1/terraform-provider-ct-v0.3.1-linux-amd64.tar.gz
tar xzf terraform-provider-ct-v0.3.1-linux-amd64.tar.gz
mv terraform-provider-ct-v0.3.1-linux-amd64/terraform-provider-ct ~/.terraform.d/plugins/terraform-provider-ct_v0.3.1
```

Binary names are versioned. This enables the ability to upgrade different plugins and have clusters pin different versions.

```
$ tree ~/.terraform.d/
/home/user/.terraform.d/
└── plugins
    ├── terraform-provider-ct_v0.2.1
    ├── terraform-provider-ct_v0.3.0
    ├── terraform-provider-ct_v0.3.1
    └── terraform-provider-matchbox_v0.2.3
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

## Terraform v0.12.x

Terraform [v0.12](https://www.hashicorp.com/blog/announcing-terraform-0-12) introduced major changes to the provider plugin protocol and HCL language (first-class expressions, formal list and map types, nullable variables, variable constraints, and short-circuiting ternary operators).

Typhoon modules have been adapted for Terraform v0.12. Provider plugins requirements now enforce v0.12 compatibility. However, some HCL language changes were breaking (list [type hint](https://www.terraform.io/upgrade-guides/0-12.html#referring-to-list-variables) workarounds in v0.11 now have new meaning). Typhoon cannot offer both v0.11 and v0.12 compatibility in the same release. Upcoming releases require upgrading Terraform to v0.12.

| Typhoon Release   | Terraform version   |
|-------------------|---------------------|
| v1.16.3 - ?       | v0.12.x             |
| v1.10.3 - v1.16.3 | v0.11.x             |
| v1.9.2 - v1.10.2  | v0.10.4+ or v0.11.x |
| v1.7.3 - v1.9.1   | v0.10.x             |
| v1.6.4 - v1.7.2   | v0.9.x              |

### New users

New users can start with Terraform v0.12.x and follow the docs for Typhoon v1.16.3+ without issue.

### Existing users

Migrate from Terraform v0.11 to v0.12 either **in-place** (easier, riskier) or by **moving resources** (safer, tedious).

Install [Terraform](https://www.terraform.io/downloads.html) v0.12.x on your system alongside Terraform v0.11.x.

```shell
sudo ln -sf ~/Downloads/terraform-0.12.0/terraform /usr/local/bin/terraform12
```

!!! note
    For example, `terraform` may refer Terraform v0.11.14, while `terraform12` is symlinked to Terraform v0.12.1. Once migration is complete, Terraform v0.11.x can be deleted and `terraform12` renamed.

#### In-place

For existing Typhoon v1.14.2 or v1.14.3 clusters, edit the Typhoon `ref` to first SHA that introduced Terraform v0.12 support (`3276bf587850218b8f967978a4bf2b05d5f440a2`). The aim is to minimize the diff and convert to using Terraform v0.12.x. For example:

```tf
 module "bare-metal-mercury" {
-  source = "git::https://github.com/poseidon/typhoon//bare-metal/container-linux/kubernetes?ref=v1.14.3"
+  source = "git::https://github.com/poseidon/typhoon//bare-metal/container-linux/kubernetes?ref=3276bf587850218b8f967978a4bf2b05d5f440a2"
   ...
```

With Terraform v0.12, Typhoon clusters no longer require the `providers` block (unless you actually need to pass an [aliased provider](https://www.terraform.io/docs/configuration/providers.html#alias-multiple-provider-instances)). A regression in Terraform v0.11 made it neccessary to explicitly pass aliased providers in order for Typhoon to continue to enforce constraints (see [terraform#16824](https://github.com/hashicorp/terraform/issues/16824)). Terraform v0.12 resolves this issue.

```tf
 module "bare-metal-mercury" {
   source = "git::https://github.com/poseidon/typhoon//bare-metal/container-linux/kubernetes?ref=3276bf587850218b8f967978a4bf2b05d5f440a2"

-  providers = {
-    local = "local.default"
-    null = "null.default"
-    template = "template.default"
-    tls = "tls.default"
-  }
```

Provider constrains ensure suitable plugin versions are used. Install new versions of `terraform-provider-ct` (v0.3.2+) and `terraform-provider-matchbox` (bare-metal only, v0.3.0+) according to the [changelog](https://github.com/poseidon/typhoon/blob/master/CHANGES.md#v1144) or tutorial docs. The `local`, `null`, `template`, and `tls` blocks in `providers.tf` are no longer needed.

```tf
 provider "matchbox" {
-  version     = "0.2.3"
+  version     = "0.3.0"
   endpoint    = "matchbox.example.com:8081"
   client_cert = "${file("~/.config/matchbox/client.crt")}"
   client_key  = "${file("~/.config/matchbox/client.key")}"
 }

 provider "ct" {
-  version = "0.3.2"
+  version = "0.3.3"
 }
-
-provider "local" {
-  version = "~> 1.0"
-  alias = "default"
-}
-
-provider "null" {
-  version = "~> 1.0"
-  alias = "default"
-}
-
-provider "template" {
-  version = "~> 1.0"
-  alias = "default"
-}
-
-provider "tls" {
-  version = "~> 1.0"
-  alias = "default"
-}
```

Within the Terraform config directory (i.e. working directory), initialize to fetch suitable provider plugins.

```shell
terraform12 init  # using Terraform v0.12 binary, not v0.11
```

Use the Terraform v0.12 upgrade subcommand to convert v0.11 syntax to v0.12. This _will_ edit resource definitions in `*.tf` files in the working directory. Start from a clean version control state. Inspect the changes. Resolve any "TODO" items.

```shell
terraform12 0.12upgrade
git diff
```

Finally, plan.

```shell
terraform12 plan
```

Verify no changes are proposed and commit changes to version control. You've migrated to Terraform v0.12! Repeat for other config directories. Use the Terraform v0.12 binary going forward.

!!! note
    It is known that plan may propose re-creating `template_dir` resources. This is harmless.

!!! error
    If plan produced errors, seek to address them (they may be in non-Typhoon resources). If plan proposed a diff, you'll need to evaluate whether that's expected and safe to apply. In-place edits between Typhoon releases aren't supported (favoring blue/green replacement). The larger the version skew, the greater the risk. Use good judgement. If in doubt, abandon the generated changes, delete `.terraform` as [suggested](https://www.terraform.io/upgrade-guides/0-12.html#upgrading-to-terraform-0-12), and try the move resources approach.

#### Moving Resources

Alternately, continue maintaining existing clusters using Terraform v0.11.x and existing Terraform configuration directory(ies). Create new Terraform directory(ies) and move resources there to be managed with Terraform v0.12. This approach allows resources to be migrated incrementally and ensures existing resources can always be managed (e.g. emergency patches).

Create a new Terraform [config directory](/architecture/concepts#organize) for *new* resources.

```shell
mkdir infra2
tree .
├── infraA  <- existing Terraform v0.11.x configs
└── infraB  <- new Terraform v0.12.x configs
```

Define Typhoon clusters in the new config directory using Terraform v0.12 syntax. Follow the Typhoon v1.16.3+ docs (e.g. use `terraform12` in the `infraB` dir). See [AWS](/cl/aws), [Azure](/cl/azure), [Bare-Metal](/cl/bare-metal), [Digital Ocean](/cl/digital-ocean), or [Google-Cloud](/cl/google-cloud)) to create new clusters. Follow the usual [upgrade](/topics/maintenance/#upgrades) process to apply workloads and shift traffic. Later, switch back to the old config directory and deprovision clusters with Terraform v0.11.

```shell
terraform12 init
terraform12 plan
terraform12 apply
```

Your Terraform configuration directory likely defines resources other than just Typhoon modules (e.g. application DNS records, firewall rules, etc.). While such migrations are outside Typhoon's scope, you'll probably want to move existing resource definitions into your new Terraform configuration directory. Use Terraform v0.12 to import the resource into the state associated with the new config directory (to avoid trying to recreate a resource that exists). Then with Terraform v0.11 in the old directory, remove the resource from the state (to avoid trying to delete the resource). Verify neither `plan` produces a diff.

```sh
# move google_dns_record_set.some-app from infraA to infraB
cd infraA
terraform state list
terraform state show google_dns_record_set.some-app

cd ../infraB
terraform12 import google_dns_record_set.some-app SOMEID
terraform12 plan

cd ../infraA
terraform state rm google_dns_record_set.some-app
terraform plan
```

