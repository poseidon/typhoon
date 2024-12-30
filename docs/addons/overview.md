# Components

Typhoon's component model allows for managing cluster components independent from the cluster's lifecycle, upgrading in a rolling or automated fashion, or customizing components in advanced ways.

Typhoon clusters install core components like `CoreDNS`, `kube-proxy`, and a chosen CNI provider (`flannel` or `cilium`) by default. Since v1.30.1, pre-installed components are optional. Other "addon" components like Nginx Ingress, Prometheus, or Grafana may be optionally applied though the component model (after cluster creation).

## Components

Pre-installed by default:

* CoreDNS
* kube-proxy
* CNI provider (set via `var.networking`)
    * flannel
    * Cilium

Addons:

* Nginx [Ingress Controller](ingress.md)
* [Prometheus](prometheus.md)
* [Grafana](grafana.md)
* [fleetlock](fleetlock.md)

## Pre-installed Components

By default, Typhoon clusters install `CoreDNS`, `kube-proxy`, and a chosen CNI provider (`flannel` or `cilium`). Disable any or all of these components using the `components` system.

```tf
module "yavin" {
  source = "git::https://github.com/poseidon/typhoon//google-cloud/fedora-coreos/kubernetes?ref=v1.30.1"

  # Google Cloud
  cluster_name  = "yavin"
  region        = "us-central1"
  dns_zone      = "example.com"
  dns_zone_name = "example-zone"

  # configuration
  ssh_authorized_key = "ssh-ed25519 AAAAB3Nz..."

  # pre-installed components (defaults shown)
  components = {
    enable = true
    coredns = {
      enable = true
    }
    kube_proxy = {
      enable = true
    }
    # Only the CNI set in var.networking will be installed
    flannel = {
      enable = true
    }
    cilium = {
      enable = true
    }
  }
}
```

!!! warn
    Disabling pre-installed components is for advanced users who intend to manage these components separately. Without a CNI provider, cluster nodes will be NotReady and wait for the CNI provider to be applied.

## Managing Components

If you choose to manage components youself, a recommended pattern is to use a separate Terraform workspace per component, like you would any application.

```
mkdir -p infra/components/{coredns, cilium}

tree components/coredns
components/coredns/
├── backend.tf
├── manifests.tf
└── providers.tf
```

Let's consider managing CoreDNS resources. Configure the `kubernetes` provider to use the kubeconfig credentials of your Typhoon cluster(s) in a `providers.tf` file. Here we show provider blocks for interacting with Typhoon clusters on AWS, Azure, or Google Cloud, assuming each cluster's `kubeconfig-admin` output was written to local file.

```tf
provider "kubernetes" {
  alias       = "aws"
  config_path = "~/.kube/configs/aws-config"
}

provider "kubernetes" {
  alias       = "google"
  config_path = "~/.kube/configs/google-config"
}

...
```

Typhoon maintains Terraform modules for most addon components. You can reference `main`, a tagged release, a SHA revision, or custom module of your own. Define the CoreDNS manifests using the `addons/coredns` module in a `manifests.tf` file.

```tf
# CoreDNS manifests for the aws cluster
module "aws" {
  source = "git::https://github.com/poseidon/typhoon//addons/coredns?ref=v1.30.1"
  providers = {
    kubernetes = kubernetes.aws
  }
}

# CoreDNS manifests for the google cloud cluster
module "aws" {
  source = "git::https://github.com/poseidon/typhoon//addons/coredns?ref=v1.30.1"
  providers = {
    kubernetes = kubernetes.google
  }
}
...
```

Plan and apply the CoreDNS Kubernetes resources to cluster(s).

```
terraform plan
terraform apply
...
module.aws.kubernetes_service_account.coredns: Refreshing state... [id=kube-system/coredns]
module.aws.kubernetes_config_map.coredns: Refreshing state... [id=kube-system/coredns]
module.aws.kubernetes_cluster_role.coredns: Refreshing state... [id=system:coredns]
module.aws.kubernetes_cluster_role_binding.coredns: Refreshing state... [id=system:coredns]
module.aws.kubernetes_service.coredns: Refreshing state... [id=kube-system/coredns]
...
```
