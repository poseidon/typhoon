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
  source = "git::https://github.com/poseidon/typhoon//bare-metal/container-linux/kubernetes?ref=v1.11.2"
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
