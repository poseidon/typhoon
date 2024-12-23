# Bare-Metal

In this tutorial, we'll network boot and provision a Kubernetes v1.32.0 cluster on bare-metal with Fedora CoreOS.

First, we'll deploy a [Matchbox](https://github.com/poseidon/matchbox) service and setup a network boot environment. Then, we'll declare a Kubernetes cluster using the Typhoon Terraform module and power on machines. On PXE boot, machines will install Fedora CoreOS to disk, reboot into the disk install, and provision themselves as Kubernetes controllers or workers via Ignition.

Controller hosts are provisioned to run an `etcd-member` peer and a `kubelet` service. Worker hosts run a `kubelet` service. Controller nodes run `kube-apiserver`, `kube-scheduler`, `kube-controller-manager`, and `coredns`, while `kube-proxy` and (`flannel`, `calico`, or `cilium`) run on every node. A generated `kubeconfig` provides `kubectl` access to the cluster.

## Requirements

* Machines with 2GB RAM, 30GB disk, PXE-enabled NIC, IPMI
* PXE-enabled [network boot](https://coreos.com/matchbox/docs/latest/network-setup.html) environment (with HTTPS support)
* Matchbox v0.6+ deployment with API enabled
* Matchbox credentials `client.crt`, `client.key`, `ca.crt`
* Terraform v0.13.0+

## Machines

Collect a MAC address from each machine. For machines with multiple PXE-enabled NICs, pick one of the MAC addresses. MAC addresses will be used to match machines to profiles during network boot.

* 52:54:00:a1:9c:ae (node1)
* 52:54:00:b2:2f:86 (node2)
* 52:54:00:c3:61:77 (node3)

Configure each machine to boot from the disk through IPMI or the BIOS menu.

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

Create an iPXE-enabled network boot environment. Configure PXE clients to chainload [iPXE](http://ipxe.org/cmd) firmware compiled to support [HTTPS downloads](https://ipxe.org/crypto). Instruct iPXE clients to chainload from your Matchbox service's `/boot.ipxe` endpoint.

For networks already supporting iPXE clients, you can add a `default.ipxe` config.

```ini
# /var/www/html/ipxe/default.ipxe
chain http://matchbox.foo:8080/boot.ipxe
```

For networks with Ubiquiti Routers, you can [configure the router](/topics/hardware/#ubiquiti) itself to chainload machines to iPXE and Matchbox.

Read about the [many ways](https://coreos.com/matchbox/docs/latest/network-setup.html) to setup a compliant iPXE-enabled network. There is quite a bit of flexibility:

* Continue using existing DHCP, TFTP, or DNS services
* Configure specific machines, subnets, or architectures to chainload from Matchbox
* Place Matchbox behind a menu entry (timeout and default to Matchbox)

!!! note ""
    TFTP chainloading to modern boot firmware, like iPXE, avoids issues with old NICs and allows faster transfer protocols like HTTP to be used.

!!! warning
    Compile iPXE from [source](https://github.com/ipxe/ipxe) with support for [HTTPS downloads](https://ipxe.org/crypto). iPXE's pre-built firmware binaries do not enable this. Fedora CoreOS downloads are HTTPS-only.

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

Configure the Matchbox provider to use your Matchbox API endpoint and client certificate in a `providers.tf` file.

```tf
provider "matchbox" {
  endpoint    = "matchbox.example.com:8081"
  client_cert = file("~/.config/matchbox/client.crt")
  client_key  = file("~/.config/matchbox/client.key")
  ca          = file("~/.config/matchbox/ca.crt")
}

provider "ct" {}

terraform {
  required_providers {
    ct = {
      source  = "poseidon/ct"
      version = "0.13.0"
    }
    matchbox = {
      source = "poseidon/matchbox"
      version = "0.5.2"
    }
  }
}
```

## Cluster

Define a Kubernetes cluster using the module `bare-metal/fedora-coreos/kubernetes`.

```tf
module "mercury" {
  source = "git::https://github.com/poseidon/typhoon//bare-metal/fedora-coreos/kubernetes?ref=v1.32.0"

  # bare-metal
  cluster_name            = "mercury"
  matchbox_http_endpoint  = "http://matchbox.example.com"
  os_stream               = "stable"
  os_version              = "32.20201104.3.0"

  # configuration
  k8s_domain_name    = "node1.example.com"
  ssh_authorized_key = "ssh-ed25519 AAAAB3Nz..."

  # machines
  controllers = [{
    name   = "node1"
    mac    = "52:54:00:a1:9c:ae"
    domain = "node1.example.com"
  }]
  workers = [
    {
      name   = "node2",
      mac    = "52:54:00:b2:2f:86"
      domain = "node2.example.com"
    },
    {
      name   = "node3",
      mac    = "52:54:00:c3:61:77"
      domain = "node3.example.com"
    }
  ]
}
```

Workers with similar features can be defined inline using the `workers` field as shown above. It's also possible to define discrete workers that attach to the cluster. Discrete workers are more advanced, but more verbose.

```tf
module "mercury-node1" {
  source = "git::https://github.com/poseidon/typhoon//bare-metal/fedora-coreos/kubernetes/worker?ref=v1.32.0"

  # bare-metal
  cluster_name = "mercury"
  matchbox_http_endpoint  = "http://matchbox.example.com"
  os_stream               = "stable"
  os_version              = "32.20201104.3.0"

  # configuration
  name               = "node2"
  mac                = "52:54:00:b2:2f:86"
  domain             = "node2.example.com"
  kubeconfig         = module.mercury.kubeconfig
  ssh_authorized_key = "ssh-ed25519 AAAAB3Nz..."

  # optional
  snippets       = []
  node_labels    = []
  node_tains     = []
  install_disk   = "/dev/vda"
  cached_install = false
}

...
```

Reference the [variables docs](#variables) or the [variables.tf](https://github.com/poseidon/typhoon/blob/master/bare-metal/fedora-coreos/kubernetes/variables.tf) source.

## ssh-agent

Initial bootstrapping requires `bootstrap.service` be started on one controller node. Terraform uses `ssh-agent` to automate this step. Add your SSH private key to `ssh-agent`.

```sh
ssh-add ~/.ssh/id_ed25519
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
Plan: 55 to add, 0 to change, 0 to destroy.
```

Apply the changes. Terraform will generate bootstrap assets and create Matchbox profiles (e.g. controller, worker) and matching rules via the Matchbox API.

```sh
$ terraform apply
module.mercury.null_resource.copy-kubeconfig.0: Provisioning with 'file'...
module.mercury.null_resource.copy-etcd-secrets.0: Provisioning with 'file'...
module.mercury.null_resource.copy-kubeconfig.0: Still creating... (10s elapsed)
module.mercury.null_resource.copy-etcd-secrets.0: Still creating... (10s elapsed)
...
```

Apply will then loop until it can successfully copy credentials to each machine and start the one-time Kubernetes bootstrap service. Proceed to the next step while this loops.

### Power

Power on each machine with the boot device set to `pxe` for the next boot only.

```sh
ipmitool -H node1.example.com -U USER -P PASS chassis bootdev pxe
ipmitool -H node1.example.com -U USER -P PASS power on
```

Machines will network boot, install Fedora CoreOS to disk, reboot into the disk install, and provision themselves as controllers or workers.

!!! tip ""
    If this is the first test of your PXE-enabled network boot environment, watch the SOL console of a machine to spot any misconfigurations.

### Bootstrap

Wait for the `bootstrap` step to finish bootstrapping the Kubernetes control plane. This may take 5-15 minutes depending on your network.

```
module.mercury.null_resource.bootstrap: Still creating... (6m10s elapsed)
module.mercury.null_resource.bootstrap: Still creating... (6m20s elapsed)
module.mercury.null_resource.bootstrap: Still creating... (6m30s elapsed)
module.mercury.null_resource.bootstrap: Still creating... (6m40s elapsed)
module.mercury.null_resource.bootstrap: Creation complete (ID: 5441741360626669024)

Apply complete! Resources: 55 added, 0 changed, 0 destroyed.
```

To watch the bootstrap process in detail, SSH to the first controller and journal the logs.

```
$ ssh core@node1.example.com
$ journalctl -f -u bootstrap
podman[1750]: The connection to the server cluster.example.com:6443 was refused - did you specify the right host or port?
podman[1750]: Waiting for static pod control plane
...
podman[1750]: serviceaccount/calico-node unchanged
systemd[1]: Started Kubernetes control plane.
```

## Verify

[Install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) on your system. Obtain the generated cluster `kubeconfig` from module outputs (e.g. write to a local file).

```
resource "local_file" "kubeconfig-mercury" {
  content         = module.mercury.kubeconfig-admin
  filename        = "/home/user/.kube/configs/mercury-config"
  file_permission = "0600"
}
```

List nodes in the cluster.

```
$ export KUBECONFIG=/home/user/.kube/configs/mercury-config
$ kubectl get nodes
NAME                STATUS  ROLES   AGE  VERSION
node1.example.com   Ready   <none>  10m  v1.32.0
node2.example.com   Ready   <none>  10m  v1.32.0
node3.example.com   Ready   <none>  10m  v1.32.0
```

List the pods.

```
$ kubectl get pods --all-namespaces
NAMESPACE     NAME                                       READY     STATUS    RESTARTS   AGE
kube-system   cilium-6qp7f                               1/1       Running   1          11m
kube-system   cilium-gnjrm                               1/1       Running   0          11m
kube-system   cilium-llbgt                               1/1       Running   0          11m
kube-system   cilium-operator-68d778b448-g744f           1/1       Running   0          11m
kube-system   coredns-1187388186-dj3pd                   1/1       Running   0          11m
kube-system   coredns-1187388186-mx9rt                   1/1       Running   0          11m
kube-system   kube-apiserver-node1.example.com           1/1       Running   0          11m
kube-system   kube-controller-manager-node1.example.com  1/1       Running   1          11m
kube-system   kube-proxy-50sd4                           1/1       Running   0          11m
kube-system   kube-proxy-bczhp                           1/1       Running   0          11m
kube-system   kube-proxy-mp2fw                           1/1       Running   0          11m
kube-system   kube-scheduler-node1.example.com           1/1       Running   0          11m
```

## Going Further

Learn about [maintenance](/topics/maintenance/) and [addons](/addons/overview/).

## Variables

Check the [variables.tf](https://github.com/poseidon/typhoon/blob/master/bare-metal/fedora-coreos/kubernetes/variables.tf) source.

### Required

| Name | Description | Example |
|:-----|:------------|:--------|
| cluster_name | Unique cluster name | "mercury" |
| matchbox_http_endpoint | Matchbox HTTP read-only endpoint | "http://matchbox.example.com:port" |
| os_stream | Fedora CoreOS release stream | "stable" |
| os_version | Fedora CoreOS version to PXE and install | "32.20201104.3.0" |
| k8s_domain_name | FQDN resolving to the controller(s) nodes. Workers and kubectl will communicate with this endpoint | "myk8s.example.com" |
| ssh_authorized_key | SSH public key for user 'core' | "ssh-ed25519 AAAAB3Nz..." |
| controllers | List of controller machine detail objects (unique name, identifying MAC address, FQDN) | `[{name="node1", mac="52:54:00:a1:9c:ae", domain="node1.example.com"}]` |

### Optional

| Name | Description | Default | Example |
|:-----|:------------|:--------|:--------|
| workers | List of worker machine detail objects (unique name, identifying MAC address, FQDN) | [] | `[{name="node2", mac="52:54:00:b2:2f:86", domain="node2.example.com"}, {name="node3", mac="52:54:00:c3:61:77", domain="node3.example.com"}]` |
| cached_install | PXE boot and install from the Matchbox `/assets` cache. Admin MUST have downloaded Fedora CoreOS images into the cache | false | true |
| install_disk | Disk device where Fedora CoreOS should be installed | "sda" (not "/dev/sda" like Container Linux) | "sdb" |
| networking | Choice of networking provider | "cilium" | "calico" or "cilium" or "flannel" |
| network_mtu | CNI interface MTU (calico-only) | 1480 | - |
| snippets | Map from machine names to lists of Butane snippets | {} | [examples](/advanced/customization/) |
| network_ip_autodetection_method | Method to detect host IPv4 address (calico-only) | "first-found" | "can-reach=10.0.0.1" |
| pod_cidr | CIDR IPv4 range to assign to Kubernetes pods | "10.20.0.0/14" | "10.22.0.0/16" |
| service_cidr | CIDR IPv4 range to assign to Kubernetes services | "10.3.0.0/16" | "10.3.0.0/24" |
| kernel_args | Additional kernel args to provide at PXE boot | [] | ["kvm-intel.nested=1"] |
| worker_node_labels | Map from worker name to list of initial node labels | {} | {"node2" = ["role=special"]} |
| worker_node_taints | Map from worker name to list of initial node taints | {} | {"node2" = ["role=special:NoSchedule"]} |
