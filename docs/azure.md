# Azure

In this tutorial, we'll create a Kubernetes v1.9.3 cluster on Azure.

We'll declare a Kubernetes cluster in Terraform using the Typhoon Terraform module. On apply, an Azure Virtual Network, subnets, Availability Sets for controllers and workers, load balancers for controllers and workers, and network security groups will be created.

Controllers and workers are provisioned to run a `kubelet`. A one-time [bootkube](https://github.com/kubernetes-incubator/bootkube) bootstrap schedules an `apiserver`, `scheduler`, `controller-manager`, and `kube-dns` on controllers and runs `kube-proxy` and `flannel` on each node. A generated `kubeconfig` provides `kubectl` access to the cluster.

## Requirements

* Azure Account and AAD credentials
* Azure DNS Zone (registered Domain Name or delegated subdomain)
* Terraform v0.11.x and [terraform-provider-ct](https://github.com/coreos/terraform-provider-ct) installed locally

## Terraform Setup

Install [Terraform](https://www.terraform.io/downloads.html) v0.11.x on your system.

```sh
$ terraform version
Terraform v0.11.1
```

Add the [terraform-provider-ct](https://github.com/coreos/terraform-provider-ct) plugin binary for your system.

```sh
wget https://github.com/coreos/terraform-provider-ct/releases/download/v0.2.0/terraform-provider-ct-v0.2.0-linux-amd64.tar.gz
tar xzf terraform-provider-ct-v0.2.0-linux-amd64.tar.gz
sudo mv terraform-provider-ct-v0.2.0-linux-amd64/terraform-provider-ct /usr/local/bin/
```

Add the plugin to your `~/.terraformrc`.

```
providers {
  ct = "/usr/local/bin/terraform-provider-ct"
}
```

Read [concepts](concepts.md) to learn about Terraform, modules, and organizing resources. Change to your infrastructure repository (e.g. `infra`).

```
cd infra/clusters
```

## Provider

Credentials are required to provision resources using the `azurerm` provider.

Using environment variables is the suggested method for storing authentication information:
```bash
export ARM_CLIENT_ID="<arm_client_id>"
export ARM_CLIENT_SECRET="<arm_client_secret>"
export ARM_SUBSCRIPTION_ID="<arm_subscription_id>"
export ARM_TENANT_ID="<arm_tenant_id>"
```

Configure the Azure provider to use your access key credentials in a `providers.tf` file.

```tf
provider "azurerm" {
  version = "~> 1.1"
  alias   = "default"
}

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

Additional configuration options are described in the `azurerm` provider [docs](https://www.terraform.io/docs/providers/azurerm/).

!!! tip
    Regions are listed in [docs](https://azure.microsoft.com/en-us/regions/) or with `az account list-locations -o table`.

## Cluster

Define a Kubernetes cluster using the module `azure/container-linux/kubernetes`.

```tf
module "azure-foo" {
  source = "git::https://github.com/justaugustus/typhoon-azure//azure/container-linux/kubernetes?ref=v1.9.3-azure.0"

  providers = {
    azure = "azure.default"
    local = "local.default"
    null = "null.default"
    template = "template.default"
    tls = "tls.default"
  }

  cluster_name = "foo"
  location     = "eastus2"

  # Azure
  dns_zone           = "azure.example.com"
  dns_zone_rg        = "dns-resource-group"
  controller_count   = 3
  controller_type    = "Standard_DS2_v2"
  worker_count       = 2
  worker_type        = "Standard_DS2_v2"
  os_channel         = "stable"
  ssh_authorized_key = "${file("/home/<user>/.ssh/id_rsa.pub")}"

  # bootkube
  asset_dir = "/home/augustus/.secrets/clusters/foo"
}
```

Reference the [variables docs](#variables) or the [variables.tf](https://github.com/justaugustus/typhoon-azure/blob/azure/azure/container-linux/kubernetes/variables.tf) source.

## ssh-agent

Initial bootstrapping requires `bootkube.service` be started on one controller node. Terraform uses `ssh-agent` to automate this step. Add your SSH private key to `ssh-agent`.

```sh
ssh-add ~/.ssh/id_rsa
ssh-add -L
```

!!! warning
    `terraform apply` will hang connecting to a controller if `ssh-agent` does not contain the SSH key.

## Apply

Initialize the config directory if this is the first use with Terraform.

```sh
terraform init
```

Get or update Terraform modules.

```sh
$ terraform get            # downloads missing modules
$ terraform get --update   # updates all modules
Get: git::https://github.com/justaugustus/typhoon-azure (update)
Get: git::https://github.com/poseidon/bootkube-terraform.git?ref=v0.10.0 (update)
```

Plan the resources to be created.

```sh
$ terraform plan
Plan: 98 to add, 0 to change, 0 to destroy.
```

Apply the changes to create the cluster.

```sh
$ terraform apply
...
module.azure-foo.null_resource.bootkube-start: Still creating... (4m50s elapsed)
module.azure-foo.null_resource.bootkube-start: Still creating... (5m0s elapsed)
module.azure-foo.null_resource.bootkube-start: Creation complete after 11m8s (ID: 3961816482286168143)

Apply complete! Resources: 98 added, 0 changed, 0 destroyed.
```

In 4-8 minutes, the Kubernetes cluster will be ready.

## Verify

[Install kubectl](https://coreos.com/kubernetes/docs/latest/configure-kubectl.html) on your system. Use the generated `kubeconfig` credentials to access the Kubernetes cluster and list nodes.

```
$ export KUBECONFIG=/home/user/.secrets/clusters/foo/auth/kubeconfig
$ kubectl get nodes
NAME             STATUS    AGE       VERSION        
ip-10-0-12-221   Ready     34m       v1.9.3
ip-10-0-19-112   Ready     34m       v1.9.3
ip-10-0-4-22     Ready     34m       v1.9.3
```

List the pods.

```
$ kubectl get pods --all-namespaces
NAMESPACE     NAME                                      READY  STATUS    RESTARTS  AGE              
kube-system   calico-node-1m5bf                         2/2    Running   0         34m              
kube-system   calico-node-7jmr1                         2/2    Running   0         34m              
kube-system   calico-node-bknc8                         2/2    Running   0         34m              
kube-system   kube-apiserver-4mjbk                      1/1    Running   0         34m              
kube-system   kube-controller-manager-3597210155-j2jbt  1/1    Running   1         34m              
kube-system   kube-controller-manager-3597210155-j7g7x  1/1    Running   0         34m              
kube-system   kube-dns-1187388186-wx1lg                 3/3    Running   0         34m              
kube-system   kube-proxy-14wxv                          1/1    Running   0         34m              
kube-system   kube-proxy-9vxh2                          1/1    Running   0         34m              
kube-system   kube-proxy-sbbsh                          1/1    Running   0         34m              
kube-system   kube-scheduler-3359497473-5plhf           1/1    Running   0         34m              
kube-system   kube-scheduler-3359497473-r7zg7           1/1    Running   1         34m              
kube-system   pod-checkpointer-4kxtl                    1/1    Running   0         34m              
kube-system   pod-checkpointer-4kxtl-ip-10-0-12-221     1/1    Running   0         33m
```

## Going Further

Learn about [version pinning](concepts.md#versioning), [maintenance](topics/maintenance.md), and [addons](addons/overview.md).

!!! note
    On Container Linux clusters, install the `container-linux-update-operator` addon to coordinate reboots and drains when nodes auto-update. Otherwise, updates may not be applied until the next reboot.

## Variables

### Required

| Name | Description | Example |
|:-----|:------------|:--------|
| location | Azure location to create resources | "eastus2" |
| cluster_name | Unique cluster name (prepended to dns_zone) | "foo" |
| dns_zone | Azure DNS zone | "azure.example.com" |
| dns_zone_rg | Resource group of Azure DNS zone | "dns-resource-group" |
| ssh_authorized_key | SSH public key for ~/.ssh_authorized_keys | "ssh-rsa AAAAB3NZ..." |
| os_channel | Container Linux AMI channel | stable, beta, alpha |
| asset_dir | Path to a directory where generated assets should be placed (contains secrets) | "/home/user/.secrets/clusters/foo" |

#### DNS Zone

Clusters create a DNS A record `${cluster_name}.${dns_zone}` to resolve a network load balancer backed by controller instances. This FQDN is used by workers and `kubectl` to access the apiserver. In this example, the cluster's apiserver would be accessible at `foo.azure.example.com`.

You'll need a registered domain name or subdomain registered in an Azure DNS zone. You can set this up once and create many clusters with unique names.

```tf
resource "azurerm_resource_group" "typhoon" {
  name     = "dns-resource-group"
  location = "East US 2"
}

resource "azurerm_dns_zone" "typhoon" {
  name                = "azure.example.com"
  resource_group_name = "${azurerm_resource_group.typhoon.name}"
}
```

Reference the DNS zone id with `"${azurerm_dns_zone.typhoon.id}"`.

### Optional

| Name | Description | Default | Example |
|:-----|:------------|:--------|:--------|
| controller_count | Number of controllers (i.e. masters) | 1 | 3 |
| controller_type | Controller VM instance type | "Standard_DS2_v2" | "Standard_DS3_v2" |
| worker_count | Number of workers | 1 | 3 |
| worker_type | Worker VM instance type | "Standard_DS2_v2" | "Standard_DS3_v2" |
| disk_size | Size of the EBS volume in GB | "40" | "100" |
| networking | Choice of networking provider | "flannel" | "flannel" |
| vnet_cidr | CIDR IPv4 range to assign to the Virtual Network | "10.0.0.0/16" | "10.1.0.0/16" |
| controller_cidr | CIDR IPv4 range to assign to controller nodes | "10.0.1.0/24" | "10.0.1.0/24" |
| worker_cidr | CIDR IPv4 range to assign to worker nodes | "10.0.1.0/24" | "10.0.1.0/24" |
| pod_cidr | CIDR range to assign to Kubernetes pods | "10.2.0.0/16" | "10.22.0.0/16" |
| service_cidr | CIDR range to assign to Kubernetes services | "10.3.0.0/16" | "10.3.0.0/24" |
| cluster_domain_suffix | FQDN suffix for Kubernetes services answered by kube-dns. | "cluster.local" | "k8s.example.com" |

Check the list of valid [instance types](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/sizes).
