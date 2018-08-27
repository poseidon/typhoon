# Google Cloud

!!! danger
    Typhoon for Fedora Atomic is alpha. Fedora does not publish official images for Google Cloud so you must prepare them yourself. Expect rough edges and changes.

In this tutorial, we'll create a Kubernetes v1.11.2 cluster on Google Compute Engine with Fedora Atomic.

We'll declare a Kubernetes cluster using the Typhoon Terraform module. Then apply the changes to create a network, firewall rules, health checks, controller instances, worker managed instance group, load balancers, and TLS assets. Instances are provisioned on first boot with cloud-init.

Controllers are provisioned to run an `etcd` peer and a `kubelet` service. Workers run just a `kubelet` service. A one-time [bootkube](https://github.com/kubernetes-incubator/bootkube) bootstrap schedules the `apiserver`, `scheduler`, `controller-manager`, and `coredns` on controllers and schedules `kube-proxy` and `calico` (or `flannel`) on every node. A generated `kubeconfig` provides `kubectl` access to the cluster.

## Requirements

* Google Cloud Account and Service Account
* Google Cloud DNS Zone (registered main Name or delegated subdomain)
* Terraform v0.11.x installed locally
* `gcloud` and `gsutil` for uploading a disk image to Google Cloud (temporary)

## Terraform Setup

Install [Terraform](https://www.terraform.io/downloads.html) v0.11.x on your system.

```sh
$ terraform version
Terraform v0.11.7
```

Read [concepts](/architecture/concepts.md) to learn about Terraform, modules, and organizing resources. Change to your infrastructure repository (e.g. `infra`).

```
cd infra/clusters
```

## Provider

Login to your Google Console [API Manager](https://console.cloud.google.com/apis/dashboard) and select a project, or [signup](https://cloud.google.com/free/) if you don't have an account.

Select "Credentials" and create a service account key. Choose the "Compute Engine Admin" role and save the JSON private key to a file that can be referenced in configs.

```sh
mv ~/Downloads/project-id-43048204.json ~/.config/google-cloud/terraform.json
```

Configure the Google Cloud provider to use your service account key, project-id, and region in a `providers.tf` file.

```tf
provider "google" {
  version = "1.6"
  alias   = "default"

  credentials = "${file("~/.config/google-cloud/terraform.json")}"
  project     = "project-id"
  region      = "us-central1"
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

Additional configuration options are described in the `google` provider [docs](https://www.terraform.io/docs/providers/google/index.html).

!!! tip
    Regions are listed in [docs](https://cloud.google.com/compute/docs/regions-zones/regions-zones) or with `gcloud compute regions list`. A project may container multiple clusters across different regions.

## Atomic Image

Project Atomic does not publish official Fedora Atomic images to Google Cloud. However, Google Cloud allows [custom boot images](https://cloud.google.com/compute/docs/images/import-existing-image) to be uploaded to a bucket and imported into your project.

Download the Fedora Atomic 28 [raw image](https://getfedora.org/en/atomic/download/) and decompress the file.

```
xz -d Fedora-AtomicHost-28-20180528.0.x86_64.raw.xz
```

!!! warning
    Download the exact dated version shown in docs. Fedora has no official Atomic images for Google Cloud. We've verified specific versions and found others to have problems.

Rename the image `disk.raw`. Gzip compress and tar the image.

```
mv Fedora-AtomicHost-28-20180528.0.x86_64.raw disk.raw
tar cvzf fedora-atomic-28.tar.gz disk.raw
```

List available storage buckets and upload the tar.gz.

```
gsutil list
gsutil cp fedora-atomic-28.tar.gz gs://BUCKET_NAME
```

Create a Google Compute Engine image from the bucket file.

```
gcloud compute images list
gcloud compute images create fedora-atomic-28 --source-uri gs://BUCKET/fedora-atomic-28.tar.gz
```

Note your project id and the image name for setting `os_image` later (e.g. proj-id/fedora-atomic-28).

## Cluster

Define a Kubernetes cluster using the module `google-cloud/fedora-atomic/kubernetes`.

```tf
module "google-cloud-yavin" {
  source = "git::https://github.com/poseidon/typhoon//google-cloud/fedora-atomic/kubernetes?ref=v1.11.2"
  
  providers = {
    google   = "google.default"
    local    = "local.default"
    null     = "null.default"
    template = "template.default"
    tls      = "tls.default"
  }

  # Google Cloud
  cluster_name  = "yavin"
  region        = "us-central1"
  dns_zone      = "example.com"
  dns_zone_name = "example-zone"

  # configuration
  ssh_authorized_key = "ssh-rsa AAAAB3Nz..."
  asset_dir          = "/home/user/.secrets/clusters/yavin"
  os_image           = "MY-PROJECT_ID/fedora-atomic-28"
  
  # optional
  worker_count = 2
}
```

Reference the [variables docs](#variables) or the [variables.tf](https://github.com/poseidon/typhoon/blob/master/google-cloud/fedora-atomic/kubernetes/variables.tf) source.

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
Plan: 73 to add, 0 to change, 0 to destroy.
```

Apply the changes to create the cluster.

```sh
$ terraform apply
module.google-cloud-yavin.null_resource.bootkube-start: Still creating... (10s elapsed)
...

module.google-cloud-yavin.null_resource.bootkube-start: Still creating... (5m30s elapsed)
module.google-cloud-yavin.null_resource.bootkube-start: Still creating... (5m40s elapsed)
module.google-cloud-yavin.null_resource.bootkube-start: Creation complete (ID: 5768638456220583358)

Apply complete! Resources: 73 added, 0 changed, 0 destroyed.
```

In 5-10 minutes, the Kubernetes cluster will be ready.

## Verify

[Install kubectl](https://coreos.com/kubernetes/docs/latest/configure-kubectl.html) on your system. Use the generated `kubeconfig` credentials to access the Kubernetes cluster and list nodes.

```
$ export KUBECONFIG=/home/user/.secrets/clusters/yavin/auth/kubeconfig
$ kubectl get nodes
NAME                                          STATUS   AGE    VERSION
yavin-controller-0.c.example-com.internal     Ready    6m     v1.11.2
yavin-worker-jrbf.c.example-com.internal      Ready    5m     v1.11.2
yavin-worker-mzdm.c.example-com.internal      Ready    5m     v1.11.2
```

List the pods.

```
$ kubectl get pods --all-namespaces
NAMESPACE     NAME                                      READY  STATUS    RESTARTS  AGE
kube-system   calico-node-1cs8z                         2/2    Running   0         6m
kube-system   calico-node-d1l5b                         2/2    Running   0         6m
kube-system   calico-node-sp9ps                         2/2    Running   0         6m
kube-system   coredns-1187388186-zj5dl                  1/1    Running   0         6m
kube-system   kube-apiserver-zppls                      1/1    Running   0         6m
kube-system   kube-controller-manager-3271970485-gh9kt  1/1    Running   0         6m
kube-system   kube-controller-manager-3271970485-h90v8  1/1    Running   1         6m
kube-system   kube-proxy-117v6                          1/1    Running   0         6m
kube-system   kube-proxy-9886n                          1/1    Running   0         6m
kube-system   kube-proxy-njn47                          1/1    Running   0         6m
kube-system   kube-scheduler-3895335239-5x87r           1/1    Running   0         6m
kube-system   kube-scheduler-3895335239-bzrrt           1/1    Running   1         6m
kube-system   pod-checkpointer-l6lrt                    1/1    Running   0         6m
```

## Going Further

Learn about [maintenance](/topics/maintenance.md) and [addons](/addons/overview.md).

## Variables

Check the [variables.tf](https://github.com/poseidon/typhoon/blob/master/google-cloud/fedora-atomic/kubernetes/variables.tf) source.

### Required

| Name | Description | Example |
|:-----|:------------|:--------|
| cluster_name | Unique cluster name (prepended to dns_zone) | "yavin" |
| region | Google Cloud region | "us-central1" |
| dns_zone | Google Cloud DNS zone | "google-cloud.example.com" |
| dns_zone_name | Google Cloud DNS zone name | "example-zone" |
| os_image | Custom uploaded Fedora Atomic image | "PROJECT-ID/fedora-atomic-28" |
| ssh_authorized_key | SSH public key for user 'fedora' | "ssh-rsa AAAAB3NZ..." |
| asset_dir | Path to a directory where generated assets should be placed (contains secrets) | "/home/user/.secrets/clusters/yavin" |

Check the list of valid [regions](https://cloud.google.com/compute/docs/regions-zones/regions-zones).

#### DNS Zone

Clusters create a DNS A record `${cluster_name}.${dns_zone}` to resolve a network load balancer backed by controller instances. This FQDN is used by workers and `kubectl` to access the apiserver(s). In this example, the cluster's apiserver would be accessible at `yavin.google-cloud.example.com`.

You'll need a registered domain name or delegated subdomain on Google Cloud DNS. You can set this up once and create many clusters with unique names.

```tf
resource "google_dns_managed_zone" "zone-for-clusters" {
  dns_name    = "google-cloud.example.com."
  name        = "example-zone"
  description = "Production DNS zone"
}
```

!!! tip ""
    If you have an existing domain name with a zone file elsewhere, just delegate a subdomain that can be managed on Google Cloud (e.g. google-cloud.mydomain.com) and [update nameservers](https://cloud.google.com/dns/update-name-servers).

### Optional

| Name | Description | Default | Example |
|:-----|:------------|:--------|:--------|
| controller_count | Number of controllers (i.e. masters) | 1 | 3 |
| worker_count | Number of workers | 1 | 3 |
| controller_type | Machine type for controllers | "n1-standard-1" | See below |
| worker_type | Machine type for workers | "n1-standard-1" | See below |
| disk_size | Size of the disk in GB | 40 | 100 |
| worker_preemptible | If enabled, Compute Engine will terminate workers randomly within 24 hours | false | true |
| networking | Choice of networking provider | "calico" | "calico" or "flannel" |
| pod_cidr | CIDR IPv4 range to assign to Kubernetes pods | "10.2.0.0/16" | "10.22.0.0/16" |
| service_cidr | CIDR IPv4 range to assign to Kubernetes services | "10.3.0.0/16" | "10.3.0.0/24" |
| cluster_domain_suffix | FQDN suffix for Kubernetes services answered by coredns. | "cluster.local" | "k8s.example.com" |

Check the list of valid [machine types](https://cloud.google.com/compute/docs/machine-types).

#### Preemption

Add `worker_preemeptible = "true"` to allow worker nodes to be [preempted](https://cloud.google.com/compute/docs/instances/preemptible) at random, but pay [significantly](https://cloud.google.com/compute/pricing) less. Clusters tolerate stopping instances fairly well (reschedules pods, but cannot drain) and preemption provides a nice reward for running fault-tolerant cluster systems.`

