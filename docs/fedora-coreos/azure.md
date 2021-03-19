# Azure

In this tutorial, we'll create a Kubernetes v1.20.5 cluster on Azure with Fedora CoreOS.

We'll declare a Kubernetes cluster using the Typhoon Terraform module. Then apply the changes to create a resource group, virtual network, subnets, security groups, controller availability set, worker scale set, load balancer, and TLS assets.

Controller hosts are provisioned to run an `etcd-member` peer and a `kubelet` service. Worker hosts run a `kubelet` service. Controller nodes run `kube-apiserver`, `kube-scheduler`, `kube-controller-manager`, and `coredns`, while `kube-proxy` and `calico` (or `flannel`) run on every node. A generated `kubeconfig` provides `kubectl` access to the cluster.

## Requirements

* Azure account
* Azure DNS Zone (registered Domain Name or delegated subdomain)
* Terraform v0.13.0+

## Terraform Setup

Install [Terraform](https://www.terraform.io/downloads.html) v0.13.0+ on your system.

```sh
$ terraform version
Terraform v0.13.0
```

Read [concepts](/architecture/concepts/) to learn about Terraform, modules, and organizing resources. Change to your infrastructure repository (e.g. `infra`).

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
  features {}
}

provider "ct" {}

terraform {
  required_providers {
    ct = {
      source  = "poseidon/ct"
      version = "0.7.1"
    }
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.48.0"
    }
  }
}
```

Additional configuration options are described in the `azurerm` provider [docs](https://www.terraform.io/docs/providers/azurerm/).

## Fedora CoreOS Images

Fedora CoreOS publishes images for Azure, but does not yet upload them. Azure allows custom images to be uploaded to a storage account bucket and imported.

[Download](https://getfedora.org/en/coreos/download?tab=cloud_operators&stream=stable) a Fedora CoreOS Azure VHD image and upload it to an Azure storage account container (i.e. bucket) via the UI (quite slow).

```
xz -d fedora-coreos-31.20200323.3.2-azure.x86_64.vhd.xz
```

Create an Azure disk (note disk ID) and create an Azure image from it (note image ID).

```
az disk create --name fedora-coreos-31.20200323.3.2 -g GROUP --source https://BUCKET.blob.core.windows.net/fedora-coreos/fedora-coreos-31.20200323.3.2-azure.x86_64.vhd

az image create --name fedora-coreos-31.20200323.3.2 -g GROUP --os-type=linux --source /subscriptions/some/path/providers/Microsoft.Compute/disks/fedora-coreos-31.20200323.3.2
```

Set the [os_image](#variables) in the next step.

## Cluster

Define a Kubernetes cluster using the module `azure/fedora-coreos/kubernetes`.

```tf
module "ramius" {
  source = "git::https://github.com/poseidon/typhoon//azure/fedora-coreos/kubernetes?ref=v1.20.5"

  # Azure
  cluster_name   = "ramius"
  region         = "centralus"
  dns_zone       = "azure.example.com"
  dns_zone_group = "example-group"

  # configuration
  os_image           = "/subscriptions/some/path/Microsoft.Compute/images/fedora-coreos-31.20200323.3.2"
  ssh_authorized_key = "ssh-rsa AAAAB3Nz..."

  # optional
  worker_count    = 2
  host_cidr       = "10.0.0.0/20"
}
```

Reference the [variables docs](#variables) or the [variables.tf](https://github.com/poseidon/typhoon/blob/master/azure/fedora-coreos/kubernetes/variables.tf) source.

## ssh-agent

Initial bootstrapping requires `bootstrap.service` be started on one controller node. Terraform uses `ssh-agent` to automate this step. Add your SSH private key to `ssh-agent`.

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
module.ramius.null_resource.bootstrap: Still creating... (6m50s elapsed)
module.ramius.null_resource.bootstrap: Still creating... (7m0s elapsed)
module.ramius.null_resource.bootstrap: Creation complete after 7m8s (ID: 3961816482286168143)

Apply complete! Resources: 69 added, 0 changed, 0 destroyed.
```

In 4-8 minutes, the Kubernetes cluster will be ready.

## Verify

[Install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) on your system. Obtain the generated cluster `kubeconfig` from module outputs (e.g. write to a local file).

```
resource "local_file" "kubeconfig-ramius" {
  content  = module.ramius.kubeconfig-admin
  filename = "/home/user/.kube/configs/ramius-config"
}
```

List nodes in the cluster.

```
$ export KUBECONFIG=/home/user/.kube/configs/ramius-config
$ kubectl get nodes
NAME                  STATUS  ROLES   AGE  VERSION
ramius-controller-0   Ready   <none>  24m  v1.20.5
ramius-worker-000001  Ready   <none>  25m  v1.20.5
ramius-worker-000002  Ready   <none>  24m  v1.20.5
```

List the pods.

```
$ kubectl get pods --all-namespaces
NAMESPACE     NAME                                        READY  STATUS    RESTARTS  AGE
kube-system   coredns-7c6fbb4f4b-b6qzx                    1/1    Running   0         26m
kube-system   coredns-7c6fbb4f4b-j2k3d                    1/1    Running   0         26m
kube-system   calico-node-1m5bf                           2/2    Running   0         26m
kube-system   calico-node-7jmr1                           2/2    Running   0         26m
kube-system   calico-node-bknc8                           2/2    Running   0         26m
kube-system   kube-apiserver-ramius-controller-0          1/1    Running   0         26m
kube-system   kube-controller-manager-ramius-controller-0 1/1    Running   0         26m
kube-system   kube-proxy-j4vpq                            1/1    Running   0         26m
kube-system   kube-proxy-jxr5d                            1/1    Running   0         26m
kube-system   kube-proxy-lbdw5                            1/1    Running   0         26m
kube-system   kube-scheduler-ramius-controller-0          1/1    Running   0         26m
```

## Going Further

Learn about [maintenance](/topics/maintenance/) and [addons](/addons/overview/).

## Variables

Check the [variables.tf](https://github.com/poseidon/typhoon/blob/master/azure/fedora-coreos/kubernetes/variables.tf) source.

### Required

| Name | Description | Example |
|:-----|:------------|:--------|
| cluster_name | Unique cluster name (prepended to dns_zone) | "ramius" |
| region | Azure region | "centralus" |
| dns_zone | Azure DNS zone | "azure.example.com" |
| dns_zone_group | Resource group where the Azure DNS zone resides | "global" |
| os_image | Fedora CoreOS image for instances | "/subscriptions/..../custom-image" |
| ssh_authorized_key | SSH public key for user 'core' | "ssh-rsa AAAAB3NZ..." |

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
  resource_group_name = azurerm_resource_group.global.name

  name      = "azure.example.com"
  zone_type = "Public"
}
```

Reference the DNS zone with `azurerm_dns_zone.clusters.name` and its resource group with `"azurerm_resource_group.global.name`.

!!! tip ""
    If you have an existing domain name with a zone file elsewhere, just delegate a subdomain that can be managed on Azure DNS (e.g. azure.mydomain.com) and [update nameservers](https://docs.microsoft.com/en-us/azure/dns/dns-delegate-domain-azure-dns).

### Optional

| Name | Description | Default | Example |
|:-----|:------------|:--------|:--------|
| controller_count | Number of controllers (i.e. masters) | 1 | 1 |
| worker_count | Number of workers | 1 | 3 |
| controller_type | Machine type for controllers | "Standard_B2s" | See below |
| worker_type | Machine type for workers | "Standard_DS1_v2" | See below |
| disk_size | Size of the disk in GB | 40 | 100 |
| worker_priority | Set priority to Spot to use reduced cost surplus capacity, with the tradeoff that instances can be deallocated at any time | Regular | Spot |
| controller_snippets | Controller Fedora CoreOS Config snippets | [] | [example](/advanced/customization/#usage) |
| worker_snippets | Worker Fedora CoreOS Config snippets | [] | [example](/advanced/customization/#usage) |
| networking | Choice of networking provider | "calico" | "calico" or "cilium" or "flannel" |
| host_cidr | CIDR IPv4 range to assign to instances | "10.0.0.0/16" | "10.0.0.0/20" |
| pod_cidr | CIDR IPv4 range to assign to Kubernetes pods | "10.2.0.0/16" | "10.22.0.0/16" |
| service_cidr | CIDR IPv4 range to assign to Kubernetes services | "10.3.0.0/16" | "10.3.0.0/24" |
| worker_node_labels | List of initial worker node labels | [] | ["worker-pool=default"] |

Check the list of valid [machine types](https://azure.microsoft.com/en-us/pricing/details/virtual-machines/linux/) and their [specs](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/sizes-general). Use `az vm list-skus` to get the identifier.

!!! warning
    Unlike AWS and GCP, Azure requires its *virtual* networks to have non-overlapping IPv4 CIDRs (yeah, go figure). Instead of each cluster just using `10.0.0.0/16` for instances, each Azure cluster's `host_cidr` must be non-overlapping (e.g. 10.0.0.0/20 for the 1st cluster, 10.0.16.0/20 for the 2nd cluster, etc).

!!! warning
    Do not choose a `controller_type` smaller than `Standard_B2s`. Smaller instances are not sufficient for running a controller.

#### Spot Priority

Add `worker_priority=Spot` to use [Spot Priority](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/spot-vms) workers that run on Azure's surplus capacity at lower cost, but with the tradeoff that they can be deallocated at random. Spot priority VMs are Azure's analog to AWS spot instances or GCP premptible instances.
