# Concepts

Let's cover the concepts you'll need to get started.

## Kubernetes

[Kubernetes](https://kubernetes.io/) is an open-source cluster system for deploying, scaling, and managing containerized applications across a pool of compute nodes (bare-metal, droplets, instances).

#### Nodes

All cluster nodes provision themselves from a declarative configuration upfront. Nodes run a `kubelet` service and register themselves with the control plane to join the cluster. All nodes run `kube-proxy` and `calico` or `flannel` pods.

#### Controllers

Controller nodes are scheduled to run the Kubernetes `apiserver`, `scheduler`, `controller-manager`, `coredns`, and `kube-proxy`. A fully qualified domain name (e.g. cluster_name.domain.com) resolving to a network load balancer or round-robin DNS (depends on platform) is used to refer to the control plane.

#### Workers

Worker nodes register with the control plane and run application workloads.

## Terraform

Terraform config files declare *resources* that Terraform should manage. Resources include infrastructure components created through a *provider* API (e.g. Compute instances, DNS records) or local assets like TLS certificates and config files.

```tf
# Declare an instance
resource "google_compute_instance" "pet" {
  # ...
}
```

The `terraform` tool parses configs, reconciles the desired state with actual state, and updates resources to reach desired state.

```sh
$ terraform plan
Plan: 4 to add, 0 to change, 0 to destroy.
$ terraform apply
Apply complete! Resources: 4 added, 0 changed, 0 destroyed.
```

With Typhoon, you'll be able to manage clusters with Terraform.

### Modules

Terraform [modules](https://www.terraform.io/docs/modules/usage.html) allow a collection of resources to be configured and managed together. Typhoon provides a Kubernetes cluster Terraform *module* for each [supported](/#modules) platform and operating system.

Clusters are declared in Terraform by referencing the module.

```tf
module "google-cloud-yavin" {
  source = "git::https://github.com/poseidon/typhoon//google-cloud/container-linux/kubernetes"
  cluster_name = "yavin"
  ...
}
```

### Versioning

Modules are updated regularly, set the version to a [release tag](https://github.com/poseidon/typhoon/releases) or [commit](https://github.com/poseidon/typhoon/commits/master) hash.

```tf
...
source = "git:https://github.com/poseidon/typhoon//google-cloud/container-linux/kubernetes?ref=hash"
```

Module versioning ensures `terraform get --update` only fetches the desired version, so plan and apply don't change cluster resources, unless the version is altered.

### Organize

Maintain Terraform configs for "live" infrastructure in a versioned repository. Seek to organize configs to reflect resources that should be managed together in a `terraform apply` invocation.

You may choose to organize resources all together, by team, by project, or some other scheme. Here's an example that manages four clusters together:

```sh
.git/
infra/
└── terraform
    └── clusters
        ├── aws-tempest.tf
        ├── azure-ramius.tf
        ├── bare-metal-mercury.tf
        ├── google-cloud-yavin.tf
        ├── digital-ocean-nemo.tf
        ├── providers.tf
        ├── terraform.tfvars
        └── remote-backend.tf
```

By convention, `providers.tf` registers provider APIs, `terraform.tfvars` stores shared values, and state is written to a remote backend.

### State

Terraform syncs its state with provider APIs to plan changes to reconcile to the desired state. By default, Terraform writes state data (including secrets!) to a `terraform.tfstate` file. **At a minimum**, add a `.gitignore` file (or equivalent) to prevent state from being committed to your infrastructure repository.

```
# .gitignore
*.tfstate
*.tfstate.backup
.terraform/
```

### Remote Backend

Later, you may wish to checkout Terraform [remote backends](https://www.terraform.io/intro/getting-started/remote.html) which store state in a remote bucket like Google Storage or S3.

```
terraform {
  backend "gcs" {
    credentials = "/path/to/credentials.json"
    project     = "project-id"
    bucket      = "bucket-id"
    path        = "metal.tfstate"
  }
}
```

