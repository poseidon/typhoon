# Bare-Metal

In this tutorial, we'll network boot and provision a Kubernetes v1.9.3 cluster on bare-metal.

First, we'll deploy a [Matchbox](https://github.com/coreos/matchbox) service and setup a network boot environment. Then, we'll declare a Kubernetes cluster in Terraform using the Typhoon Terraform module and power on machines. On PXE boot, machines will install Container Linux to disk, reboot into the disk install, and provision themselves as Kubernetes controllers or workers.

Controllers are provisioned as etcd peers and run `etcd-member` (etcd3) and `kubelet`. Workers are provisioned to run a `kubelet`. A one-time [bootkube](https://github.com/kubernetes-incubator/bootkube) bootstrap schedules an `apiserver`, `scheduler`, `controller-manager`, and `kube-dns` on controllers and runs `kube-proxy` and `calico` or `flannel` on each node. A generated `kubeconfig` provides `kubectl` access to the cluster.

## Requirements

* Machines with 2GB RAM, 30GB disk, PXE-enabled NIC, IPMI
* PXE-enabled [network boot](https://coreos.com/matchbox/docs/latest/network-setup.html) environment
* Matchbox v0.6+ deployment with API enabled
* Matchbox credentials `client.crt`, `client.key`, `ca.crt`
* Terraform v0.11.x and [terraform-provider-matchbox](https://github.com/coreos/terraform-provider-matchbox) installed locally

## Machines

Collect a MAC address from each machine. For machines with multiple PXE-enabled NICs, pick one of the MAC addresses. MAC addresses will be used to match machines to profiles during network boot.

* 52:54:00:a1:9c:ae (node1)
* 52:54:00:b2:2f:86 (node2)
* 52:54:00:c3:61:77 (node3)

Configure each machine to boot from the disk [^1] through IPMI or the BIOS menu.


[^1]: Configuring "diskless" workers that always PXE boot is possible, but not in the scope of this tutorial.

```
ipmitool -H node1 -U USER -P PASS chassis bootdev disk options=persistent
```
 
During provisioning, you'll explicitly set the boot device to `pxe` for the next boot only. Machines will install (overwrite) the operating system to disk on PXE boot and reboot into the disk install.

!!! tip ""
    Ask your hardware vendor to provide MACs and preconfigure IPMI, if possible. With it, you can rack new servers, `terraform apply` with new info, and power on machines that network boot and provision into clusters.

## DNS

Create a DNS A (or AAAA) record for each node's default interface. Create a record that resolves to each controller node (or re-use the node record if there's one controller).

* node1.example.com (node1)
* node2.example.com (node2)
* node3.example.com (node3)
* myk8s.example.com (node1)

Cluster nodes will be configured to refer to the control plane and themselves by these fully qualified names and they'll be used in generated TLS certificates.

## Matchbox

Matchbox is an open-source app that matches network-booted bare-metal machines (based on labels like MAC, UUID, etc.) to profiles to automate cluster provisioning.

Install Matchbox on a Kubernetes cluster or dedicated server.

* Installing on [Kubernetes](https://coreos.com/matchbox/docs/latest/deployment.html#kubernetes) (recommended)
* Installing on a [server](https://coreos.com/matchbox/docs/latest/deployment.html#download)

!!! tip
    Deploy Matchbox as service that can be accessed by all of your bare-metal machines globally. This provides a single endpoint to use Terraform to manage bare-metal clusters at different sites. Typhoon will never include secrets in provisioning user-data so you may even deploy matchbox publicly.

Matchbox provides a TLS client-authenticated API that clients, like Terraform, can use to manage machine matching and profiles. Think of it like a cloud provider API, but for creating bare-metal instances.

[Generate TLS](https://coreos.com/matchbox/docs/latest/deployment.html#generate-tls-certificates) client credentials. Save the `ca.crt`, `client.crt`, and `client.key` where they can be referenced in Terraform configs.

```sh
mv ca.crt client.crt client.key ~/.config/matchbox/
```

Verify the matchbox read-only HTTP endpoints are accessible (port is configurable).

```sh
$ curl http://matchbox.example.com:8080
matchbox
```

Verify your TLS client certificate and key can be used to access the Matchbox API (port is configurable).

```sh
$ openssl s_client -connect matchbox.example.com:8081 \
  -CAfile ~/.config/matchbox/ca.crt \
  -cert ~/.config/matchbox/client.crt \
  -key ~/.config/matchbox/client.key
```

## PXE Environment

Create a iPXE-enabled network boot environment. Configure PXE clients to chainload [iPXE](http://ipxe.org/cmd) and instruct iPXE clients to chainload from your Matchbox service's `/boot.ipxe` endpoint.

For networks already supporting iPXE clients, you can add a `default.ipxe` config.

```ini
# /var/www/html/ipxe/default.ipxe
chain http://matchbox.foo:8080/boot.ipxe
```

For networks with Ubiquiti Routers, you can [configure the router](/topics/hardware.md#ubiquiti) itself to chainload machines to iPXE and Matchbox.

For a small lab, you may wish to checkout the [quay.io/coreos/dnsmasq](https://quay.io/repository/coreos/dnsmasq) container image and [copy-paste examples](https://github.com/coreos/matchbox/blob/master/Documentation/network-setup.md#coreosdnsmasq).

Read about the [many ways](https://coreos.com/matchbox/docs/latest/network-setup.html) to setup a compliant iPXE-enabled network. There is quite a bit of flexibility:

* Continue using existing DHCP, TFTP, or DNS services
* Configure specific machines, subnets, or architectures to chainload from Matchbox
* Place Matchbox behind a menu entry (timeout and default to Matchbox)

!!! note ""
    TFTP chainloading to modern boot firmware, like iPXE, avoids issues with old NICs and allows faster transfer protocols like HTTP to be used.

## Terraform Setup

Install [Terraform](https://www.terraform.io/downloads.html) v0.11.x on your system.

```sh
$ terraform version
Terraform v0.11.1
```

Add the [terraform-provider-matchbox](https://github.com/coreos/terraform-provider-matchbox) plugin binary for your system.

```sh
wget https://github.com/coreos/terraform-provider-matchbox/releases/download/v0.2.2/terraform-provider-matchbox-v0.2.2-linux-amd64.tar.gz
tar xzf terraform-provider-matchbox-v0.2.2-linux-amd64.tar.gz
sudo mv terraform-provider-matchbox-v0.2.2-linux-amd64/terraform-provider-matchbox /usr/local/bin/
```

Add the plugin to your `~/.terraformrc`.

```
providers {
  matchbox = "/usr/local/bin/terraform-provider-matchbox"
}
```

Read [concepts](concepts.md) to learn about Terraform, modules, and organizing resources. Change to your infrastructure repository (e.g. `infra`).

```
cd infra/clusters
```

## Provider

Configure the Matchbox provider to use your Matchbox API endpoint and client certificate in a `providers.tf` file.

```tf
provider "matchbox" {
  endpoint    = "matchbox.example.com:8081"
  client_cert = "${file("~/.config/matchbox/client.crt")}"
  client_key  = "${file("~/.config/matchbox/client.key")}"
  ca          = "${file("~/.config/matchbox/ca.crt")}"
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

## Cluster

Define a Kubernetes cluster using the module `bare-metal/container-linux/kubernetes`.

```tf
module "bare-metal-mercury" {
  source = "git::https://github.com/poseidon/typhoon//bare-metal/container-linux/kubernetes?ref=v1.9.3"
  
  providers = {
    local = "local.default"
    null = "null.default"
    template = "template.default"
    tls = "tls.default"
  }
  
  # install
  matchbox_http_endpoint  = "http://matchbox.example.com"
  container_linux_channel = "stable"
  container_linux_version = "1576.5.0"
  ssh_authorized_key      = "ssh-rsa AAAAB3Nz..."

  # cluster
  cluster_name    = "mercury"
  k8s_domain_name = "node1.example.com"

  # machines
  controller_names   = ["node1"]
  controller_macs    = ["52:54:00:a1:9c:ae"]
  controller_domains = ["node1.example.com"]
  worker_names = [
    "node2",
    "node3",
  ]
  worker_macs = [
    "52:54:00:b2:2f:86",
    "52:54:00:c3:61:77",
  ]
  worker_domains = [
    "node2.example.com",
    "node3.example.com",
  ]

  # output assets dir
  asset_dir = "/home/user/.secrets/clusters/mercury"
}
```

Reference the [variables docs](#variables) or the [variables.tf](https://github.com/poseidon/typhoon/blob/master/bare-metal/container-linux/kubernetes/variables.tf) source.

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
Get: git::https://github.com/poseidon/typhoon (update)
Get: git::https://github.com/poseidon/bootkube-terraform.git?ref=v0.10.0 (update)
```

Plan the resources to be created.

```sh
$ terraform plan
Plan: 55 to add, 0 to change, 0 to destroy.
```

Apply the changes. Terraform will generate bootkube assets to `asset_dir` and create Matchbox profiles (e.g. controller, worker) and matching rules via the Matchbox API.

```sh
module.bare-metal-mercury.null_resource.copy-kubeconfig.0: Provisioning with 'file'...
module.bare-metal-mercury.null_resource.copy-etcd-secrets.0: Provisioning with 'file'...
module.bare-metal-mercury.null_resource.copy-kubeconfig.0: Still creating... (10s elapsed)
module.bare-metal-mercury.null_resource.copy-etcd-secrets.0: Still creating... (10s elapsed)
...
```

Apply will then loop until it can successfully copy credentials to each machine and start the one-time Kubernetes bootstrap service. Proceed to the next step while this loops.

### Power

Power on each machine with the boot device set to `pxe` for the next boot only.

```sh
ipmitool -H node1.example.com -U USER -P PASS chassis bootdev pxe
ipmitool -H node1.example.com -U USER -P PASS power on
```

Machines will network boot, install Container Linux to disk, reboot into the disk install, and provision themselves as controllers or workers.

!!! tip ""
    If this is the first test of your PXE-enabled network boot environment, watch the SOL console of a machine to spot any misconfigurations.

### Bootstrap

Wait for the `bootkube-start` step to finish bootstrapping the Kubernetes control plane. This may take 5-15 minutes depending on your network.

```
module.bare-metal-mercury.null_resource.bootkube-start: Still creating... (6m10s elapsed)
module.bare-metal-mercury.null_resource.bootkube-start: Still creating... (6m20s elapsed)
module.bare-metal-mercury.null_resource.bootkube-start: Still creating... (6m30s elapsed)
module.bare-metal-mercury.null_resource.bootkube-start: Still creating... (6m40s elapsed)
module.bare-metal-mercury.null_resource.bootkube-start: Creation complete (ID: 5441741360626669024)

Apply complete! Resources: 55 added, 0 changed, 0 destroyed.
```

To watch the bootstrap process in detail, SSH to the first controller and journal the logs.

```
$ ssh node1.example.com
$ journalctl -f -u bootkube
bootkube[5]:         Pod Status:        pod-checkpointer        Running
bootkube[5]:         Pod Status:          kube-apiserver        Running
bootkube[5]:         Pod Status:          kube-scheduler        Running
bootkube[5]:         Pod Status: kube-controller-manager        Running
bootkube[5]: All self-hosted control plane components successfully started
bootkube[5]: Tearing down temporary bootstrap control plane...
```

## Verify

[Install kubectl](https://coreos.com/kubernetes/docs/latest/configure-kubectl.html) on your system. Use the generated `kubeconfig` credentials to access the Kubernetes cluster and list nodes.

```
$ export KUBECONFIG=/home/user/.secrets/clusters/mercury/auth/kubeconfig
$ kubectl get nodes
NAME                STATUS    AGE       VERSION
node1.example.com   Ready     11m       v1.9.3
node2.example.com   Ready     11m       v1.9.3
node3.example.com   Ready     11m       v1.9.3
```

List the pods.

```
$ kubectl get pods --all-namespaces
NAMESPACE     NAME                                       READY     STATUS    RESTARTS   AGE
kube-system   calico-node-6qp7f                          2/2       Running   1          11m
kube-system   calico-node-gnjrm                          2/2       Running   0          11m
kube-system   calico-node-llbgt                          2/2       Running   0          11m
kube-system   kube-apiserver-7336w                       1/1       Running   0          11m
kube-system   kube-controller-manager-3271970485-b9chx   1/1       Running   0          11m
kube-system   kube-controller-manager-3271970485-v30js   1/1       Running   1          11m
kube-system   kube-dns-1187388186-mx9rt                  3/3       Running   0          11m
kube-system   kube-etcd-network-checkpointer-q24f7       1/1       Running   0          11m
kube-system   kube-proxy-50sd4                           1/1       Running   0          11m
kube-system   kube-proxy-bczhp                           1/1       Running   0          11m
kube-system   kube-proxy-mp2fw                           1/1       Running   0          11m
kube-system   kube-scheduler-3895335239-fd3l7            1/1       Running   1          11m
kube-system   kube-scheduler-3895335239-hfjv0            1/1       Running   0          11m
kube-system   pod-checkpointer-wf65d                     1/1       Running   0          11m
kube-system   pod-checkpointer-wf65d-node1.example.com   1/1       Running   0          11m
```

## Going Further

Learn about [version pinning](concepts.md#versioning), [maintenance](topics/maintenance.md), and [addons](addons/overview.md).

!!! note
    On Container Linux clusters, install the `container-linux-update-operator` addon to coordinate reboots and drains when nodes auto-update. Otherwise, updates may not be applied until the next reboot.

## Variables

### Required

| Name | Description | Example |
|:-----|:------------|:--------|
| matchbox_http_endpoint | Matchbox HTTP read-only endpoint | http://matchbox.example.com:8080 |
| container_linux_channel | Container Linux channel | stable, beta, alpha |
| container_linux_version | Container Linux version of the kernel/initrd to PXE and the image to install | 1576.5.0 |
| cluster_name | Cluster name | mercury |
| k8s_domain_name | FQDN resolving to the controller(s) nodes. Workers and kubectl will communicate with this endpoint | "myk8s.example.com" |
| ssh_authorized_key | SSH public key for ~/.ssh/authorized_keys | "ssh-rsa AAAAB3Nz..." |
| controller_names | Ordered list of controller short names | ["node1"] |
| controller_macs | Ordered list of controller identifying MAC addresses | ["52:54:00:a1:9c:ae"] |
| controller_domains | Ordered list of controller FQDNs | ["node1.example.com"] |
| worker_names | Ordered list of worker short names | ["node2", "node3"] |
| worker_macs | Ordered list of worker identifying MAC addresses | ["52:54:00:b2:2f:86", "52:54:00:c3:61:77"] |
| worker_domains | Ordered list of worker FQDNs | ["node2.example.com", "node3.example.com"] |
| asset_dir | Path to a directory where generated assets should be placed (contains secrets) | "/home/user/.secrets/clusters/mercury" |

### Optional

| Name | Description | Default | Example |
|:-----|:------------|:--------|:--------|
| cached_install | Whether machines should PXE boot and install from the Matchbox `/assets` cache. Admin MUST have downloaded Container Linux images into the cache to use this | false | true |
| install_disk | Disk device where Container Linux should be installed | "/dev/sda" | "/dev/sdb" |
| container_linux_oem | Specify alternative OEM image ids for the disk install | "" | "vmware_raw", "xen" |
| networking | Choice of networking provider | "calico" | "calico" or "flannel" |
| network_mtu | CNI interface MTU (calico-only) | 1480 | - | 
| pod_cidr | CIDR range to assign to Kubernetes pods | "10.2.0.0/16" | "10.22.0.0/16" |
| service_cidr | CIDR range to assign to Kubernetes services | "10.3.0.0/16" | "10.3.0.0/24" |
| cluster_domain_suffix | FQDN suffix for Kubernetes services answered by kube-dns. | "cluster.local" | "k8s.example.com" |
| kernel_args | Additional kernel args to provide at PXE boot | [] | "kvm-intel.nested=1" |

