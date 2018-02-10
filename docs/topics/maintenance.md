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
  source = "git::https://github.com/poseidon/typhoon//bare-metal/container-linux/kubernetes?ref=v1.9.3"
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
* Discourages reliance on in-place opqaue state. Retain confidence in your ability to create infrastructure from scratch.
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

Re-provision a new cluster by following the bare-metal [tutorial](../bare-metal.md#cluster).

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

Typhoon uses a self-hosted Kubernetes control plane which allows certain manifest upgrades to be performed in-place. Components like `apiserver`, `controller-manager`, `scheduler`, `flannel`/`calico`, `kube-dns`, and `kube-proxy` are run on Kubernetes itself and can be edited via `kubectl`. If you're interested, see the bootkube [upgrade docs](https://github.com/kubernetes-incubator/bootkube/blob/master/Documentation/upgrading.md).

In certain scenarios, in-place edits can be useful for quickly rolling out security patches (e.g. bumping `kube-dns`) or prioritizing speed over the safety of a proper cluster re-provision and transition.

!!! note
    Rarely, we may test certain security in-place edits and mention them as an option in release notes.

!!! warning
    Typhoon does not support or document in-place edits as an upgrade strategy. They involve inherent risks and we choose not to make recommendations or guarentees about the safety of different in-place upgrades. Its explicitly a non-goal.

#### Node Replacement

Typhoon supports multi-controller clusters, so it is possible to upgrade a cluster by deleting and replacing nodes one by one.

!!! warning
    Typhoon does not support or document node replacement as an upgrade strategy. It limits Typhoon's ability to make infrastructure and architectural changes between tagged releases. 

## Terraform v0.11.x

Terraform v0.10.x to v0.11.x introduced breaking changes in the provider and module inheritance relationship that you MUST be aware of when upgrading to the v0.11.x `terraform` binary. Terraform now allows multiple named (i.e. aliased) copies of a provider to exist (e.g `aws.default`, `aws.somename`). Terraform now also requires providers be explicitly passed to modules in order to satisfy module version contraints (which Typhoon modules define). Full details can be found in [typhoon#77](https://github.com/poseidon/typhoon/issues/77) and [hashicorp#16824](https://github.com/hashicorp/terraform/issues/16824).

In particular, after upgrading to the v0.11.x `terraform` binary, you'll notice:

* `terraform plan` does not succeed and prompts for variables when it didn't before
* `terraform plan` does not succeed and mentions "provider configuration block is required for all operations"
* `terraform apply` fails when you comment or remove a module usage in order to delete a cluster

### New users

New users can start with Terraform v0.11.x and follow the Typhoon docs without issue.

### Existing

Users who used modules to create clusters with Terraform v0.10.x and still manage those clusters via Terraform must explicitly add each provider used in `provider.tf`:

```
provider "local" {
  version = "~> 1.0"
  alias = "default"
}

provider "null" {
  version = "~> 1.0"
  alias = "default"
}

provider "template" {
  version = "~> 1.0"
  alias = "default"
}

provider "tls" {
  version = "~> 1.0"
  alias = "default"
}
```

Modify the `google`, `aws`, or `digitalocean` provider section to specify an explicit `alias` name.

```
provider "digitalocean" {
  version = "0.1.2"
  token = "${chomp(file("~/.config/digital-ocean/token"))}"
  alias = "default"
}
```

!!! note
    In these examples, we've chosen to name each provider "default", though the point of the Terraform changes is that other possibilities are possible.

Edit each instance (i.e. usage) of a module and explicitly pass the providers.

```
module "aws-cluster" {
  source = "git::https://github.com/poseidon/typhoon//aws/container-linux/kubernetes"
  
  providers = {
    aws = "aws.default"
    local = "local.default"
    null = "null.default"
    template = "template.default"
    tls = "tls.default"
  }

  cluster_name = "somename"
```

Re-run `terraform plan`. Plan will claim there are no changes to apply. Run `terraform apply` anyway as this will update Terraform state to be aware of the explicit provider versions.

### Verify

You should now be able to run `terraform plan` without errors. When you choose, you may comment or delete a module from Terraform configs and `terraform apply` should destroy the cluster correctly.
