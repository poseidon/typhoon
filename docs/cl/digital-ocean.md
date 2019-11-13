# Digital Ocean

In this tutorial, we'll create a Kubernetes v1.16.3 cluster on DigitalOcean with Container Linux.

We'll declare a Kubernetes cluster using the Typhoon Terraform module. Then apply the changes to create controller droplets, worker droplets, DNS records, tags, and TLS assets.

Controller hosts are provisioned to run an `etcd-member` peer and a `kubelet` service. Worker hosts run a `kubelet` service. Controller nodes run `kube-apiserver`, `kube-scheduler`, `kube-controller-manager`, and `coredns`, while `kube-proxy` and `calico` (or `flannel`) run on every node. A generated `kubeconfig` provides `kubectl` access to the cluster.

## Requirements

* Digital Ocean Account and Token
* Digital Ocean Domain (registered Domain Name or delegated subdomain)
* Terraform v0.12.x and [terraform-provider-ct](https://github.com/poseidon/terraform-provider-ct) installed locally

## Terraform Setup

Install [Terraform](https://www.terraform.io/downloads.html) v0.12.x on your system.

```sh
$ terraform version
Terraform v0.12.12
```

Add the [terraform-provider-ct](https://github.com/poseidon/terraform-provider-ct) plugin binary for your system to `~/.terraform.d/plugins/`, noting the final name.

```sh
wget https://github.com/poseidon/terraform-provider-ct/releases/download/v0.4.0/terraform-provider-ct-v0.4.0-linux-amd64.tar.gz
tar xzf terraform-provider-ct-v0.4.0-linux-amd64.tar.gz
mv terraform-provider-ct-v0.4.0-linux-amd64/terraform-provider-ct ~/.terraform.d/plugins/terraform-provider-ct_v0.4.0
```

Read [concepts](/architecture/concepts/) to learn about Terraform, modules, and organizing resources. Change to your infrastructure repository (e.g. `infra`).

```
cd infra/clusters
```

## Provider

Login to [DigitalOcean](https://cloud.digitalocean.com) or create an [account](https://cloud.digitalocean.com/registrations/new), if you don't have one.

Generate a Personal Access Token with read/write scope from the [API tab](https://cloud.digitalocean.com/settings/api/tokens). Write the token to a file that can be referenced in configs.

```sh
mkdir -p ~/.config/digital-ocean
echo "TOKEN" > ~/.config/digital-ocean/token
```

Configure the DigitalOcean provider to use your token in a `providers.tf` file.

```tf
provider "digitalocean" {
  version = "1.11.0"
  token = "${chomp(file("~/.config/digital-ocean/token"))}"
}

provider "ct" {
  version = "0.4.0"
}
```

## Cluster

Define a Kubernetes cluster using the module `digital-ocean/container-linux/kubernetes`.

```tf
module "digital-ocean-nemo" {
  source = "git::https://github.com/poseidon/typhoon//digital-ocean/container-linux/kubernetes?ref=v1.16.3"

  # Digital Ocean
  cluster_name = "nemo"
  region       = "nyc3"
  dns_zone     = "digital-ocean.example.com"

  # configuration
  ssh_fingerprints = ["d7:9d:79:ae:56:32:73:79:95:88:e3:a2:ab:5d:45:e7"]
  asset_dir        = "/home/user/.secrets/clusters/nemo"
  
  # optional
  worker_count = 2
}
```

Reference the [variables docs](#variables) or the [variables.tf](https://github.com/poseidon/typhoon/blob/master/digital-ocean/container-linux/kubernetes/variables.tf) source.

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
Plan: 54 to add, 0 to change, 0 to destroy.
```

Apply the changes to create the cluster.

```sh
$ terraform apply
module.digital-ocean-nemo.null_resource.bootstrap: Still creating... (30s elapsed)
module.digital-ocean-nemo.null_resource.bootstrap: Provisioning with 'remote-exec'...
...
module.digital-ocean-nemo.null_resource.bootstrap: Still creating... (6m20s elapsed)
module.digital-ocean-nemo.null_resource.bootstrap: Creation complete (ID: 7599298447329218468)

Apply complete! Resources: 54 added, 0 changed, 0 destroyed.
```

In 3-6 minutes, the Kubernetes cluster will be ready.

## Verify

[Install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) on your system. Use the generated `kubeconfig` credentials to access the Kubernetes cluster and list nodes.

```
$ export KUBECONFIG=/home/user/.secrets/clusters/nemo/auth/kubeconfig
$ kubectl get nodes
NAME               STATUS  ROLES   AGE  VERSION
10.132.110.130     Ready   <none>  10m  v1.16.3
10.132.115.81      Ready   <none>  10m  v1.16.3
10.132.124.107     Ready   <none>  10m  v1.16.3
```

List the pods.

```
NAMESPACE     NAME                                       READY     STATUS    RESTARTS   AGE
kube-system   coredns-1187388186-ld1j7                   1/1       Running   0          11m
kube-system   coredns-1187388186-rdhf7                   1/1       Running   0          11m
kube-system   calico-node-1m5bf                          2/2       Running   0          11m              
kube-system   calico-node-7jmr1                          2/2       Running   0          11m              
kube-system   calico-node-bknc8                          2/2       Running   0          11m              
kube-system   kube-apiserver-ip-10.132.115.81            1/1       Running   0          11m
kube-system   kube-controller-manager-ip-10.132.115.81   1/1       Running   0          11m
kube-system   kube-proxy-6kxjf                           1/1       Running   0          11m
kube-system   kube-proxy-fh3td                           1/1       Running   0          11m
kube-system   kube-proxy-k35rc                           1/1       Running   0          11m
kube-system   kube-scheduler-ip-10.132.115.81            1/1       Running   0          11m
```

## Going Further

Learn about [maintenance](/topics/maintenance/) and [addons](/addons/overview/).

!!! note
    On Container Linux clusters, install the `CLUO` addon to coordinate reboots and drains when nodes auto-update. Otherwise, updates may not be applied until the next reboot.

## Variables

Check the [variables.tf](https://github.com/poseidon/typhoon/blob/master/digital-ocean/container-linux/kubernetes/variables.tf) source.

### Required

| Name | Description | Example |
|:-----|:------------|:--------|
| cluster_name | Unique cluster name (prepended to dns_zone) | "nemo" |
| region | Digital Ocean region | "nyc1", "sfo2", "fra1", tor1" |
| dns_zone | Digital Ocean domain (i.e. DNS zone) | "do.example.com" |
| ssh_fingerprints | SSH public key fingerprints | ["d7:9d..."] |
| asset_dir | Absolute path to a directory where generated assets should be placed (contains secrets) | "/home/user/.secrets/nemo" |

#### DNS Zone

Clusters create DNS A records `${cluster_name}.${dns_zone}` to resolve to controller droplets (round robin). This FQDN is used by workers and `kubectl` to access the apiserver(s). In this example, the cluster's apiserver would be accessible at `nemo.do.example.com`.

You'll need a registered domain name or delegated subdomain in Digital Ocean Domains (i.e. DNS zones). You can set this up once and create many clusters with unique names.

```tf
# Declare a DigitalOcean record to also create a zone file
resource "digitalocean_domain" "zone-for-clusters" {
  name       = "do.example.com"
  ip_address = "8.8.8.8"
}
```

!!! tip ""
    If you have an existing domain name with a zone file elsewhere, just delegate a subdomain that can be managed on DigitalOcean (e.g. do.mydomain.com) and [update nameservers](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-host-name-with-digitalocean).

#### SSH Fingerprints

DigitalOcean droplets are created with your SSH public key "fingerprint" (i.e. MD5 hash) to allow access. If your SSH public key is at `~/.ssh/id_rsa`, find the fingerprint with,

```bash
ssh-keygen -E md5 -lf ~/.ssh/id_rsa.pub | awk '{print $2}'
MD5:d7:9d:79:ae:56:32:73:79:95:88:e3:a2:ab:5d:45:e7
```

If you use `ssh-agent` (e.g. Yubikey for SSH), find the fingerprint with,

```
ssh-add -l -E md5
2048 MD5:d7:9d:79:ae:56:32:73:79:95:88:e3:a2:ab:5d:45:e7 cardno:000603633110 (RSA)
```

Digital Ocean requires the SSH public key be uploaded to your account, so you may also find the fingerprint under Settings -> Security. Finally, if you don't have an SSH key, [create one now](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/).

### Optional

| Name | Description | Default | Example |
|:-----|:------------|:--------|:--------|
| controller_count | Number of controllers (i.e. masters) | 1 | 1 |
| worker_count | Number of workers | 1 | 3 |
| controller_type | Droplet type for controllers | "s-2vcpu-2gb" | s-2vcpu-2gb, s-2vcpu-4gb, s-4vcpu-8gb, ... |
| worker_type | Droplet type for workers | "s-1vcpu-2gb" | s-1vcpu-2gb, s-2vcpu-2gb, ... |
| image | Container Linux image for instances | "coreos-stable" | coreos-stable, coreos-beta, coreos-alpha |
| controller_clc_snippets | Controller Container Linux Config snippets | [] | [example](/advanced/customization/) |
| worker_clc_snippets | Worker Container Linux Config snippets | [] | [example](/advanced/customization/) |
| networking | Choice of networking provider | "calico" | "flannel" or "calico" |
| pod_cidr | CIDR IPv4 range to assign to Kubernetes pods | "10.2.0.0/16" | "10.22.0.0/16" |
| service_cidr | CIDR IPv4 range to assign to Kubernetes services | "10.3.0.0/16" | "10.3.0.0/24" |

Check the list of valid [droplet types](https://developers.digitalocean.com/documentation/changelog/api-v2/new-size-slugs-for-droplet-plan-changes/) or use `doctl compute size list`.

!!! warning
    Do not choose a `controller_type` smaller than 2GB. Smaller droplets are not sufficient for running a controller and bootstrapping will fail.
