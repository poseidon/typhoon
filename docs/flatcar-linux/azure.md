# Azure

In this tutorial, we'll create a Kubernetes v1.32.0 cluster on Azure with Flatcar Linux.

We'll declare a Kubernetes cluster using the Typhoon Terraform module. Then apply the changes to create a resource group, virtual network, subnets, security groups, controller availability set, worker scale set, load balancer, and TLS assets.

Controller hosts are provisioned to run an `etcd-member` peer and a `kubelet` service. Worker hosts run a `kubelet` service. Controller nodes run `kube-apiserver`, `kube-scheduler`, `kube-controller-manager`, and `coredns`, while `kube-proxy` and (`flannel`, `calico`, or `cilium`) run on every node. A generated `kubeconfig` provides `kubectl` access to the cluster.

## Requirements

* Azure account
* Azure DNS Zone (registered Domain Name or delegated subdomain)
* Terraform v0.13.0+

## Terraform Setup

Install [Terraform](https://www.terraform.io/downloads.html) v0.13.0+ on your system.

```sh
$ terraform version
Terraform v1.0.0
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
      version = "0.11.0"
    }
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.50.0"
    }
  }
}
```

Additional configuration options are described in the `azurerm` provider [docs](https://www.terraform.io/docs/providers/azurerm/).

## Flatcar Linux Images

Flatcar Linux publishes images to the Azure Marketplace and requires accepting terms.

```
az vm image terms accept --publish kinvolk --offer flatcar-container-linux-free --plan stable
az vm image terms accept --publish kinvolk --offer flatcar-container-linux-free --plan stable-gen2
```

## Cluster

Define a Kubernetes cluster using the module `azure/flatcar-linux/kubernetes`.

```tf
module "ramius" {
  source = "git::https://github.com/poseidon/typhoon//azure/flatcar-linux/kubernetes?ref=v1.32.0"

  # Azure
  cluster_name   = "ramius"
  location       = "centralus"
  dns_zone       = "azure.example.com"
  dns_zone_group = "example-group"
  network_cidr   = {
    ipv4 = ["10.0.0.0/20"]
  }

  # instances
  worker_count    = 2

  # configuration
  ssh_authorized_key = "ssh-rsa AAAAB3Nz..."
}
```

Reference the [variables docs](#variables) or the [variables.tf](https://github.com/poseidon/typhoon/blob/master/azure/flatcar-linux/kubernetes/variables.tf) source.

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
  content         = module.ramius.kubeconfig-admin
  filename        = "/home/user/.kube/configs/ramius-config"
  file_permission = "0600"
}
```

List nodes in the cluster.

```
$ export KUBECONFIG=/home/user/.kube/configs/ramius-config
$ kubectl get nodes
NAME                  STATUS  ROLES   AGE  VERSION
ramius-controller-0   Ready   <none>  24m  v1.32.0
ramius-worker-000001  Ready   <none>  25m  v1.32.0
ramius-worker-000002  Ready   <none>  24m  v1.32.0
```

List the pods.

```
$ kubectl get pods --all-namespaces
NAMESPACE     NAME                                        READY  STATUS    RESTARTS  AGE
kube-system   coredns-7c6fbb4f4b-b6qzx                    1/1    Running   0         26m
kube-system   coredns-7c6fbb4f4b-j2k3d                    1/1    Running   0         26m
kube-system   cilium-1m5bf                                1/1    Running   0         26m
kube-system   cilium-7jmr1                                1/1    Running   0         26m
kube-system   cilium-bknc8                                1/1    Running   0         26m
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

Check the [variables.tf](https://github.com/poseidon/typhoon/blob/master/azure/flatcar-linux/kubernetes/variables.tf) source.

### Required

| Name | Description | Example |
|:-----|:------------|:--------|
| cluster_name | Unique cluster name (prepended to dns_zone) | "ramius" |
| location | Azure location | "centralus" |
| dns_zone | Azure DNS zone | "azure.example.com" |
| dns_zone_group | Resource group where the Azure DNS zone resides | "global" |
| ssh_authorized_key | SSH public key for user 'core' | "ssh-rsa AAAAB3NZ..." |

!!! tip
    Locations are shown in [docs](https://azure.microsoft.com/en-us/global-infrastructure/regions/) or with `az account list-locations --output table`.

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
| os_image | Channel for a Container Linux derivative | "flatcar-stable" | flatcar-stable, flatcar-beta, flatcar-alpha |
| controller_count | Number of controllers (i.e. masters) | 1 | 1 |
| controller_type | Machine type for controllers | "Standard_B2s" | See below |
| controller_disk_type | Managed disk for controllers | Premium_LRS | Standard_LRS |
| controller_disk_size | Managed disk size in GB      | 30 | 50 |
| worker_count | Number of workers | 1 | 3 |
| worker_type | Machine type for workers | "Standard_D2as_v5" | See below |
| worker_disk_type | Managed disk for workers | Standard_LRS | Premium_LRS |
| worker_disk_size | Size of the disk in GB | 30 | 100 |
| worker_ephemeral_disk | Use ephemeral local disk instead of managed disk | false | true |
| worker_priority | Set priority to Spot to use reduced cost surplus capacity, with the tradeoff that instances can be deallocated at any time | Regular | Spot |
| controller_snippets | Controller Container Linux Config snippets | [] | [example](/advanced/customization/#usage) |
| worker_snippets | Worker Container Linux Config snippets | [] | [example](/advanced/customization/#usage) |
| networking | Choice of networking provider | "cilium" | "calico" or "cilium" or "flannel" |
| network_cidr | Virtual network CIDR ranges | { ipv4 = ["10.0.0.0/16"], ipv6 = [ULA, ...] } | { ipv4 = ["10.0.0.0/20"] } |
| pod_cidr | CIDR IPv4 range to assign to Kubernetes pods | "10.20.0.0/14" | "10.22.0.0/16" |
| service_cidr | CIDR IPv4 range to assign to Kubernetes services | "10.3.0.0/16" | "10.3.0.0/24" |
| worker_node_labels | List of initial worker node labels | [] | ["worker-pool=default"] |

Check the list of valid [machine types](https://azure.microsoft.com/en-us/pricing/details/virtual-machines/linux/) and their [specs](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/sizes-general). Use `az vm list-skus` to get the identifier.

!!! warning
    Do not choose a `controller_type` smaller than `Standard_B2s`. Smaller instances are not sufficient for running a controller.

#### Spot Priority

Add `worker_priority=Spot` to use [Spot Priority](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/spot-vms) workers that run on Azure's surplus capacity at lower cost, but with the tradeoff that they can be deallocated at random. Spot priority VMs are Azure's analog to AWS spot instances or GCP premptible instances.
