# Azure

!!! danger
    Typhoon for Azure is alpha. For production, use AWS, Google Cloud, or bare-metal. As Azure matures, check [errata](https://github.com/poseidon/typhoon/wiki/Errata) for known shortcomings.

In this tutorial, we'll create a Kubernetes v1.11.2 cluster on Azure with Container Linux.

We'll declare a Kubernetes cluster using the Typhoon Terraform module. Then apply the changes to create a resource group, virtual network, subnets, security groups, controller availability set, worker scale set, load balancer, and TLS assets.

Controllers are provisioned to run an `etcd-member` peer and a `kubelet` service. Workers run just a `kubelet` service. A one-time [bootkube](https://github.com/kubernetes-incubator/bootkube) bootstrap schedules the `apiserver`, `scheduler`, `controller-manager`, and `coredns` on controllers and schedules `kube-proxy` and `flannel` on every node. A generated `kubeconfig` provides `kubectl` access to the cluster.

## Requirements

* Azure account
* Azure DNS Zone (registered Domain Name or delegated subdomain)
* Terraform v0.11.x and [terraform-provider-ct](https://github.com/coreos/terraform-provider-ct) installed locally

## Terraform Setup

Install [Terraform](https://www.terraform.io/downloads.html) v0.11.x on your system.

```sh
$ terraform version
Terraform v0.11.7
```

Add the [terraform-provider-ct](https://github.com/coreos/terraform-provider-ct) plugin binary for your system.

```sh
wget https://github.com/coreos/terraform-provider-ct/releases/download/v0.2.1/terraform-provider-ct-v0.2.1-linux-amd64.tar.gz
tar xzf terraform-provider-ct-v0.2.1-linux-amd64.tar.gz
sudo mv terraform-provider-ct-v0.2.1-linux-amd64/terraform-provider-ct /usr/local/bin/
```

Add the plugin to your `~/.terraformrc`.

```
providers {
  ct = "/usr/local/bin/terraform-provider-ct"
}
```

Read [concepts](/architecture/concepts.md) to learn about Terraform, modules, and organizing resources. Change to your infrastructure repository (e.g. `infra`).

```
cd infra/clusters
```

## Provider

[Install](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) the Azure `az` command line tool to [authenticate with Azure](https://www.terraform.io/docs/providers/azurerm/authenticating_via_azure_cli.html).

```
az login
```

Configure the Azure provider in a `providers.tf` file.

```tf
provider "azurerm" {
  version = "1.13.0"
  alias   = "default"
}

provider "local" {
  version = "~> 1.0"
  alias   = "default"
}

provider "null" {
  version = "~> 1.0"
  alias   = "default"
}

provider "template" {
  version = "~> 1.0"
  alias   = "default"
}

provider "tls" {
  version = "~> 1.0"
  alias   = "default"
}
```

Additional configuration options are described in the `azurerm` provider [docs](https://www.terraform.io/docs/providers/azurerm/).

## Cluster

Define a Kubernetes cluster using the module `azure/container-linux/kubernetes`.

```tf
module "azure-ramius" {
  source = "git::https://github.com/poseidon/typhoon//azure/container-linux/kubernetes?ref=v1.11.3"

  providers = {
    azurerm  = "azurerm.default"
    local    = "local.default"
    null     = "null.default"
    template = "template.default"
    tls      = "tls.default"
  }

  # Azure
  cluster_name   = "ramius"
  region         = "centralus"
  dns_zone       = "azure.example.com"
  dns_zone_group = "example-group"

  # configuration
  ssh_authorized_key = "ssh-rsa AAAAB3Nz..."
  asset_dir          = "/home/user/.secrets/clusters/ramius"

  # optional
  worker_count    = 3
  host_cidr       = "10.0.0.0/20"
}
```

Reference the [variables docs](#variables) or the [variables.tf](https://github.com/poseidon/typhoon/blob/master/azure/container-linux/kubernetes/variables.tf) source.

## ssh-agent

Initial bootstrapping requires `bootkube.service` be started on one controller node. Terraform uses `ssh-agent` to automate this step. Add your SSH private key to `ssh-agent`.

```sh
ssh-add ~/.ssh/id_rsa
ssh-add -L
```

## Apply

Initialize the config directory if this is the first use with Terraform.

```sh
terraform init
```

Plan the resources to be created.

```sh
$ terraform plan
Plan: 86 to add, 0 to change, 0 to destroy.
```

Apply the changes to create the cluster.

```sh
$ terraform apply
...
module.azure-ramius.null_resource.bootkube-start: Still creating... (6m50s elapsed)
module.azure-ramius.null_resource.bootkube-start: Still creating... (7m0s elapsed)
module.azure-ramius.null_resource.bootkube-start: Creation complete after 7m8s (ID: 3961816482286168143)

Apply complete! Resources: 86 added, 0 changed, 0 destroyed.
```

In 4-8 minutes, the Kubernetes cluster will be ready.

## Verify

[Install kubectl](https://coreos.com/kubernetes/docs/latest/configure-kubectl.html) on your system. Use the generated `kubeconfig` credentials to access the Kubernetes cluster and list nodes.

```
$ export KUBECONFIG=/home/user/.secrets/clusters/ramius/auth/kubeconfig
$ kubectl get nodes
NAME                  STATUS  ROLES              AGE  VERSION
ramius-controller-0   Ready   controller,master  24m  v1.11.2
ramius-worker-000001  Ready   node               25m  v1.11.2
ramius-worker-000002  Ready   node               24m  v1.11.2
ramius-worker-000005  Ready   node               24m  v1.11.2
```

List the pods.

```
$ kubectl get pods --all-namespaces
NAMESPACE     NAME                                        READY  STATUS    RESTARTS  AGE
kube-system   coredns-7c6fbb4f4b-b6qzx                    1/1    Running   0         26m
kube-system   kube-apiserver-hxgsx                        1/1    Running   3         26m
kube-system   kube-controller-manager-5ff9cd7bb6-b942n    1/1    Running   0         26m
kube-system   kube-controller-manager-5ff9cd7bb6-bbr6w    1/1    Running   0         26m
kube-system   kube-flannel-bwf24                          2/2    Running   2         26m
kube-system   kube-flannel-ks5qb                          2/2    Running   0         26m
kube-system   kube-flannel-nghsx                          2/2    Running   2         26m
kube-system   kube-flannel-tq2wg                          2/2    Running   0         26m
kube-system   kube-proxy-j4vpq                            1/1    Running   0         26m
kube-system   kube-proxy-jxr5d                            1/1    Running   0         26m
kube-system   kube-proxy-lbdw5                            1/1    Running   0         26m
kube-system   kube-proxy-v8r7c                            1/1    Running   0         26m
kube-system   kube-scheduler-5f76d69686-s4fbx             1/1    Running   0         26m
kube-system   kube-scheduler-5f76d69686-vgdgn             1/1    Running   0         26m
kube-system   pod-checkpointer-cnqdg                      1/1    Running   0         26m
kube-system   pod-checkpointer-cnqdg-ramius-controller-0  1/1    Running   0         25m
```

## Going Further

Learn about [maintenance](/topics/maintenance.md) and [addons](/addons/overview.md).

!!! note
    On Container Linux clusters, install the `CLUO` addon to coordinate reboots and drains when nodes auto-update. Otherwise, updates may not be applied until the next reboot.

## Variables

Check the [variables.tf](https://github.com/poseidon/typhoon/blob/master/azure/container-linux/kubernetes/variables.tf) source.

### Required

| Name | Description | Example |
|:-----|:------------|:--------|
| cluster_name | Unique cluster name (prepended to dns_zone) | "ramius" |
| region | Azure region | "centralus" |
| dns_zone | Azure DNS zone | "azure.example.com" |
| dns_zone_group | Resource group where the Azure DNS zone resides | "global" |
| ssh_authorized_key | SSH public key for user 'core' | "ssh-rsa AAAAB3NZ..." |
| asset_dir | Path to a directory where generated assets should be placed (contains secrets) | "/home/user/.secrets/clusters/ramius" |

!!! tip
    Regions are shown in [docs](https://azure.microsoft.com/en-us/global-infrastructure/regions/) or with `az account list-locations --output table`.

#### DNS Zone

Clusters create a DNS A record `${cluster_name}.${dns_zone}` to resolve a load balancer backed by controller instances. This FQDN is used by workers and `kubectl` to access the apiserver(s). In this example, the cluster's apiserver would be accessible at `ramius.azure.example.com`.

You'll need a registered domain name or delegated subdomain on Azure DNS. You can set this up once and create many clusters with unique names.

```tf
# Azure resource group for DNS zone
resource "azurerm_resource_group" "global" {
  name     = "global"
  location = "centralus"
}

# DNS zone for clusters
resource "azurerm_dns_zone" "clusters" {
  resource_group_name = "${azurerm_resource_group.global.name}"

  name      = "azure.example.com"
  zone_type = "Public"
}
```

Reference the DNS zone with `"${azurerm_dns_zone.clusters.name}"` and its resource group with `"${azurerm_resource_group.global.name}"`.

!!! tip ""
    If you have an existing domain name with a zone file elsewhere, just delegate a subdomain that can be managed on Azure DNS (e.g. azure.mydomain.com) and [update nameservers](https://docs.microsoft.com/en-us/azure/dns/dns-delegate-domain-azure-dns).

### Optional

| Name | Description | Default | Example |
|:-----|:------------|:--------|:--------|
| controller_count | Number of controllers (i.e. masters) | 1 | 1 |
| worker_count | Number of workers | 1 | 3 |
| controller_type | Machine type for controllers | "Standard_DS1_v2" | See below |
| worker_type | Machine type for workers | "Standard_F1" | See below |
| os_image | Channel for a Container Linux derivative | coreos-stable | coreos-stable, coreos-beta, coreos-alpha |
| disk_size | Size of the disk GB | "40" | "100" |
| worker_priority | Set priority to Low to use reduced cost surplus capacity, with the tradeoff that instances can be deallocated at any time | Regular | Low |
| controller_clc_snippets | Controller Container Linux Config snippets | [] | [example](/advanced/customization/#usage) |
| worker_clc_snippets | Worker Container Linux Config snippets | [] | [example](/advanced/customization/#usage) |
| host_cidr | CIDR IPv4 range to assign to instances | "10.0.0.0/16" | "10.0.0.0/20" |
| pod_cidr | CIDR IPv4 range to assign to Kubernetes pods | "10.2.0.0/16" | "10.22.0.0/16" |
| service_cidr | CIDR IPv4 range to assign to Kubernetes services | "10.3.0.0/16" | "10.3.0.0/24" |
| cluster_domain_suffix | FQDN suffix for Kubernetes services answered by coredns. | "cluster.local" | "k8s.example.com" |

Check the list of valid [machine types](https://azure.microsoft.com/en-us/pricing/details/virtual-machines/linux/) and their [specs](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/sizes-general). Use `az vm list-skus` to get the identifier.

!!! warning
    Unlike AWS and GCP, Azure requires its *virtual* networks to have non-overlapping IPv4 CIDRs (yeah, go figure). Instead of each cluster just using `10.0.0.0/16` for instances, each Azure cluster's `host_cidr` must be non-overlapping (e.g. 10.0.0.0/20 for the 1st cluster, 10.0.16.0/20 for the 2nd cluster, etc).

!!! warning
    Do not choose a `controller_type` smaller than `Standard_DS1_v2`. Smaller instances are not sufficient for running a controller.

#### Low Priority

Add `worker_priority=Low` to use [Low Priority](https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-use-low-priority) workers that run on Azure's surplus capacity at lower cost, but with the tradeoff that they can be deallocated at random. Low priority VMs are Azure's analog to AWS spot instances or GCP premptible instances.
