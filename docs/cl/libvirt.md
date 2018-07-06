# Libvirt

In this tutorial, boot and provision a Kubernetes v1.11.0 using a local libvirt instance.

The libvirt architecture is similar to the bare-metal one, except that it is optimized for running local clusters. Like bare-metal, load balancing between controllers is up to the end-user. For more details, see the [DNS](#dns) section below.

We'll download a base image, then use Typhoon to directly provision the virtual machines via Terraform.

Controllers are provisioned to run an `etcd-member` peer and a `kubelet` service. Workers run just a `kubelet` service. A one-time [bootkube](https://github.com/kubernetes-incubator/bootkube) bootstrap schedules the `apiserver`, `scheduler`, `controller-manager`, and `coredns` on controllers and schedules `kube-proxy` and `calico` (or `flannel`) on every node. A generated `kubeconfig` provides `kubectl` access to the cluster.

## Requirements

* At least 2 GiB free ram and 20 GiB free disk
* NetworkManager in dnsmasq mode
* libvirt / virsh
* Terraform v0.11.x and 
    - [terraform-provider-libvirt ](https://github.com/dmacvicar/terraform-provider-libvirt)
    - [terraform-provider-ct ](https://github.com/coreos/terraform-provider-ct)

## Libvirt

Libvirt is a suite of tools that manages virtual machines, storage, and networking. It does not run virtual machines directly, rather it relies on a lower-level virtualization engine such as qemu or bhyve.

You will need the `virsh` and `qemu-img` binaries installed on your system:

```
sudo dnf install libvirt-client qemu-img
```

## Container Linux Base image

You will need to manually download a Container Linux base image. Qemu supports a copy-on-write format, so this will allow for deduplication.

```
wget https://stable.release.core-os.net/amd64-usr/current/coreos_production_qemu_image.img.bz2
bunzip2 coreos_production_qemu_image.img.bz2
qemu-img resize coreos_production_qemu_image.img +8G
```

Make a note of the absolute path to this image, you'll need it later.


## DNS

Libvirt will start dnsmasq server for each cluster, and will create a DNS record for every node. By default, these names are only resolvable within the cluster. However, it is easier if the names are also resolvable on the local machine. In order to do this, you will need to put your host's NetworkManager in to `dnsmasq` mode, which will route all DNS queries through a local dnsmasq instance. Then we can instruct this dnsmasq to delegate queries for a specific domain to the libvirt resolver.

This step is optional, but recommended.

You will need to know the `machine_domain` along with `node_ip_pool`, as described [below](#cluster).

For example, if all your nodes have a common domain of `hestia.k8s` and the default  `node_ip_pool` of `192.168.120.0/24`, then your DNS server will be at `192.168.120.1`

1. Edit `/etc/NetworkManager/NetworkManager.conf` and set `dns=dnsmasq` in section `[main]`
2. Tell dnsmasq to use your cluster. The syntax is `server=/<domain>/<firstIP>`. For this example:
```
echo server=/hestia.k8s/192.168.120.1 | sudo tee /etc/NetworkManager/dnsmasq.d/typhoon.conf
```
3. `systemctl restart NetworkManager`


### APIServer name

As a cluster administrator, you are responsible for providing load balancing over the controllers. Specifically, `k8s_domain_name` must be resolvable inside the cluster for installation to succeed. However, this can be overkill for short-lived clusters.

If variable `libvirt_create_k8s_domain_name` is `1`, then an extra record will be created for the libvirt dnsmasq with the name of `k8s_domain_name` and the IP address of the first controller node. This will enable bootstrapping, but is not suitable for production use.


## Terraform Setup

Install [Terraform](https://www.terraform.io/downloads.html) v0.11.x on your system.

```sh
$ terraform version
Terraform v0.11.1
```

Install [terraform-provider-libvirt ](https://github.com/dmacvicar/terraform-provider-libvirt).

```sh
 go get github.com/dmacvicar/terraform-provider-libvirt
sudo cp $GOPATH/bin/terraform-provider-libvirt /usr/local/bin/
```


Install [terraform-provider-ct ](https://github.com/coreos/terraform-provider-ct).
```sh
 go get github.com/coreos/terraform-provider-ct
sudo cp $GOPATH/bin/terraform-provider-ct /usr/local/bin/
```

Add plugins to `.terraformrc`:
```
providers {
    ct = "/usr/local/bin/terraform-provider-ct"
    libvirt = "/usr/local/bin/terraform-provider-libvirt"
}
```

Read [concepts](../architecture/concepts.md) to learn about Terraform, modules, and organizing resources. Change to your infrastructure repository (e.g. `infra`).

```
cd infra/clusters
```

## Cluster

Define a Kubernetes cluster using the module `libvirt/container-linux/kubernetes`.

```tf
module "libvirt-hestia" {
  source = "git::https://github.com/poseidon/typhoon//libvirt/container-linux/kubernetes?ref=v1.11.0"
  
  cluster_name    = "hestia"
  base_image_path = "/home/user/coreos.img"
  machine_domain  = "hestia.k8s"

  controller_names = ["node1", "node2"]

  worker_names = [ "node5", "node6" ]

  ssh_authorized_key = "ssh-rsa AAAA..."

  asset_dir = "/home/user/.secrets/clusters/hestia"
}
```

Reference the [variables docs](#variables) or the [variables.tf](https://github.com/poseidon/typhoon/blob/master/libvirt/container-linux/kubernetes/variables.tf) source.

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
Plan: 55 to add, 0 to change, 0 to destroy.
```

Apply the changes. Terraform will generate bootkube assets to `asset_dir` and create Matchbox profiles (e.g. controller, worker) and matching rules via the Matchbox API.

```sh
$ terraform apply
...
```

Apply will create the libvirt resources, then create the machines, then copy some initial configuration via SSH.

### Bootstrap

Wait for the `bootkube-start` step to finish bootstrapping the Kubernetes control plane. This may take 5-15 minutes depending on your network.

```
module.libvirt-cluster-hestia.null_resource.bootkube-start: Creation complete (ID: 5441741360626669024)

Apply complete! Resources: 55 added, 0 changed, 0 destroyed.
```

To watch the bootstrap process in detail, SSH to the first controller and journal the logs.

```
$ ssh core@node1.hestia.k8s
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

Your `k8s_domain_name` must be resolvable on the local host. You might need to either use [dnsmasq](#dns) mode or hard-code an entry in `/etc/hosts`

```
$ export KUBECONFIG=/home/user/.secrets/clusters/hestia/auth/kubeconfig
$ kubectl get nodes
NAME                STATUS    AGE       VERSION
node1.example.com   Ready     11m       v1.11.0
node2.example.com   Ready     11m       v1.11.0
node3.example.com   Ready     11m       v1.11.0
```

List the pods.

```
$ kubectl get pods --all-namespaces
NAMESPACE     NAME                                       READY     STATUS    RESTARTS   AGE
kube-system   calico-node-6qp7f                          2/2       Running   1          11m
kube-system   calico-node-gnjrm                          2/2       Running   0          11m
kube-system   calico-node-llbgt                          2/2       Running   0          11m
kube-system   coredns-1187388186-mx9rt                   1/1       Running   0          11m
kube-system   kube-apiserver-7336w                       1/1       Running   0          11m
kube-system   kube-controller-manager-3271970485-b9chx   1/1       Running   0          11m
kube-system   kube-controller-manager-3271970485-v30js   1/1       Running   1          11m
kube-system   kube-proxy-50sd4                           1/1       Running   0          11m
kube-system   kube-proxy-bczhp                           1/1       Running   0          11m
kube-system   kube-proxy-mp2fw                           1/1       Running   0          11m
kube-system   kube-scheduler-3895335239-fd3l7            1/1       Running   1          11m
kube-system   kube-scheduler-3895335239-hfjv0            1/1       Running   0          11m
kube-system   pod-checkpointer-wf65d                     1/1       Running   0          11m
kube-system   pod-checkpointer-wf65d-node1.example.com   1/1       Running   0          11m
```

## Going Further

Learn about [maintenance](../topics/maintenance.md) and [addons](../addons/overview.md). 

!!! note
    On Container Linux clusters, install the `CLUO` addon to coordinate reboots and drains when nodes auto-update. Otherwise, updates may not be applied until the next reboot.

## Variables

Check the [variables.tf](https://github.com/poseidon/typhoon/blob/master/libvirt/container-linux/kubernetes/variables.tf) source.

### Required

| Name | Description | Example |
|:-----|:------------|:--------|
| cluster_name | Unique cluster name | hestia |
| base_image_path | Path to an uncompressed Container Linux qcow2 image | "/home/user/downloads/..." |
| machine_domain | Domain name for all machines | hestia.k8s |
| ssh_authorized_key | SSH public key for user 'core' | "ssh-rsa AAAAB3Nz..." |
| asset_dir | Path to a directory where generated assets should be placed (contains secrets) | "/home/user/.secrets/clusters/mercury" |
| k8s_domain_name | Domain name that resolves to one or more controllers | console.hestia.k8s |
| controller_names | Ordered list of controller hostnames | ["node1"] |
| worker_names | Ordered list of worker hostnames | ["node2", "node3"] |

### Optional

| Name | Description | Default | Example |
|:-----|:------------|:--------|:--------|
| controller_memory | Ram in MiB to allocate to each controller | 2048 |
| worker_memory | Ram in MiB to allocate to each worker | 2048 |
| networking | Choice of networking provider | "calico" | "calico" or "flannel" |
| network_mtu | CNI interface MTU (calico-only) | 1480 | - | 
| network_ip_autodetection_method | Method to detect host IPv4 address (calico-only) | first-found | can-reach=10.0.0.1 |
| node_ip_pool | The IP range for machines | "192.168.120.0/24" | "10.1.0.0/24" |
| pod_cidr | CIDR IPv4 range to assign to Kubernetes pods | "10.2.0.0/16" | "10.22.0.0/16" |
| service_cidr | CIDR IPv4 range to assign to Kubernetes services | "10.3.0.0/16" | "10.3.0.0/24" |
| dns_server | A resolving DNS server to use for the nodes | "8.8.8.8" | "4.2.2.2" |
| libvirt_create_k8s_domain_name | Whether or not libvirt should answer for k8s_domain_name | 1 | 0 |
