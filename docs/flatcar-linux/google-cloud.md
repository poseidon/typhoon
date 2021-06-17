# Google Cloud

In this tutorial, we'll create a Kubernetes v1.21.2 cluster on Google Compute Engine with Flatcar Linux.

We'll declare a Kubernetes cluster using the Typhoon Terraform module. Then apply the changes to create a network, firewall rules, health checks, controller instances, worker managed instance group, load balancers, and TLS assets.

Controller hosts are provisioned to run an `etcd-member` peer and a `kubelet` service. Worker hosts run a `kubelet` service. Controller nodes run `kube-apiserver`, `kube-scheduler`, `kube-controller-manager`, and `coredns`, while `kube-proxy` and `calico` (or `flannel`) run on every node. A generated `kubeconfig` provides `kubectl` access to the cluster.

## Requirements

* Google Cloud Account and Service Account
* Google Cloud DNS Zone (registered Domain Name or delegated subdomain)
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

Login to your Google Console [API Manager](https://console.cloud.google.com/apis/dashboard) and select a project, or [signup](https://cloud.google.com/free/) if you don't have an account.

Select "Credentials" and create a service account key. Choose the "Compute Engine Admin" and "DNS Administrator" roles and save the JSON private key to a file that can be referenced in configs.

```sh
mv ~/Downloads/project-id-43048204.json ~/.config/google-cloud/terraform.json
```

Configure the Google Cloud provider to use your service account key, project-id, and region in a `providers.tf` file.

```tf
provider "google" {
  project     = "project-id"
  region      = "us-central1"
  credentials = file("~/.config/google-cloud/terraform.json")
}

provider "ct" {}

terraform {
  required_providers {
    ct = {
      source  = "poseidon/ct"
      version = "0.8.0"
    }
    google = {
      source = "hashicorp/google"
      version = "3.66.1"
    }
  }
}
```

Additional configuration options are described in the `google` provider [docs](https://www.terraform.io/docs/providers/google/index.html).

!!! tip
    Regions are listed in [docs](https://cloud.google.com/compute/docs/regions-zones/regions-zones) or with `gcloud compute regions list`. A project may contain multiple clusters across different regions.

### Flatcar Linux Images

Flatcar Linux publishes Google Cloud images, but does not yet upload them. Google Cloud allows [custom boot images](https://cloud.google.com/compute/docs/images/import-existing-image) to be uploaded to a bucket and imported into your project.

[Download](https://www.flatcar-linux.org/releases/) the Flatcar Linux GCE gzipped tarball and upload it to a Google Cloud storage bucket.

```
gsutil list
gsutil cp flatcar_production_gce.tar.gz gs://BUCKET
```

Create a Compute Engine image from the file.

```
gcloud compute images create flatcar-linux-2303-4-0 --source-uri gs://BUCKET_NAME/flatcar_production_gce.tar.gz
```

Set the [os_image](#variables) in the next step.

## Cluster

Define a Kubernetes cluster using the module `google-cloud/flatcar-linux/kubernetes`.

```tf
module "yavin" {
  source = "git::https://github.com/poseidon/typhoon//google-cloud/flatcar-linux/kubernetes?ref=v1.21.2"

  # Google Cloud
  cluster_name  = "yavin"
  region        = "us-central1"
  dns_zone      = "example.com"
  dns_zone_name = "example-zone"

  # configuration
  os_image           = "flatcar-linux-2303-4-0"
  ssh_authorized_key = "ssh-rsa AAAAB3Nz..."

  # optional
  worker_count = 2
}
```

Reference the [variables docs](#variables) or the [variables.tf](https://github.com/poseidon/typhoon/blob/master/google-cloud/flatcar-linux/kubernetes/variables.tf) source.

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
Plan: 64 to add, 0 to change, 0 to destroy.
```

Apply the changes to create the cluster.

```sh
$ terraform apply
module.yavin.null_resource.bootstrap: Still creating... (10s elapsed)
...
module.yavin.null_resource.bootstrap: Still creating... (5m30s elapsed)
module.yavin.null_resource.bootstrap: Still creating... (5m40s elapsed)
module.yavin.null_resource.bootstrap: Creation complete (ID: 5768638456220583358)

Apply complete! Resources: 62 added, 0 changed, 0 destroyed.
```

In 4-8 minutes, the Kubernetes cluster will be ready.

## Verify

[Install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) on your system. Obtain the generated cluster `kubeconfig` from module outputs (e.g. write to a local file).

```
resource "local_file" "kubeconfig-yavin" {
  content  = module.yavin.kubeconfig-admin
  filename = "/home/user/.kube/configs/yavin-config"
}
```

List nodes in the cluster.

```
$ export KUBECONFIG=/home/user/.kube/configs/yavin-config
$ kubectl get nodes
NAME                                       ROLES    STATUS  AGE  VERSION
yavin-controller-0.c.example-com.internal  <none>   Ready   6m   v1.21.2
yavin-worker-jrbf.c.example-com.internal   <none>   Ready   5m   v1.21.2
yavin-worker-mzdm.c.example-com.internal   <none>   Ready   5m   v1.21.2
```

List the pods.

```
$ kubectl get pods --all-namespaces
NAMESPACE     NAME                                      READY  STATUS    RESTARTS  AGE
kube-system   calico-node-1cs8z                         2/2    Running   0         6m
kube-system   calico-node-d1l5b                         2/2    Running   0         6m
kube-system   calico-node-sp9ps                         2/2    Running   0         6m
kube-system   coredns-1187388186-dkh3o                  1/1    Running   0         6m
kube-system   coredns-1187388186-zj5dl                  1/1    Running   0         6m
kube-system   kube-apiserver-controller-0               1/1    Running   0         6m
kube-system   kube-controller-manager-controller-0      1/1    Running   0         6m
kube-system   kube-proxy-117v6                          1/1    Running   0         6m
kube-system   kube-proxy-9886n                          1/1    Running   0         6m
kube-system   kube-proxy-njn47                          1/1    Running   0         6m
kube-system   kube-scheduler-controller-0               1/1    Running   0         6m
```

## Going Further

Learn about [maintenance](/topics/maintenance/) and [addons](/addons/overview/).

## Variables

Check the [variables.tf](https://github.com/poseidon/typhoon/blob/master/google-cloud/flatcar-linux/kubernetes/variables.tf) source.

### Required

| Name | Description | Example |
|:-----|:------------|:--------|
| cluster_name | Unique cluster name (prepended to dns_zone) | "yavin" |
| region | Google Cloud region | "us-central1" |
| dns_zone | Google Cloud DNS zone | "google-cloud.example.com" |
| dns_zone_name | Google Cloud DNS zone name | "example-zone" |
| os_image | Container Linux image for compute instances | "flatcar-linux-2303-4-0" |
| ssh_authorized_key | SSH public key for user 'core' | "ssh-rsa AAAAB3NZ..." |

Check the list of valid [regions](https://cloud.google.com/compute/docs/regions-zones/regions-zones) and list Container Linux [images](https://cloud.google.com/compute/docs/images) with `gcloud compute images list | grep coreos`.

#### DNS Zone

Clusters create a DNS A record `${cluster_name}.${dns_zone}` to resolve a TCP proxy load balancer backed by controller instances. This FQDN is used by workers and `kubectl` to access the apiserver(s). In this example, the cluster's apiserver would be accessible at `yavin.google-cloud.example.com`.

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
| disk_size | Size of the disk in GB | 30 | 100 |
| worker_preemptible | If enabled, Compute Engine will terminate workers randomly within 24 hours | false | true |
| controller_snippets | Controller Container Linux Config snippets | [] | [example](/advanced/customization/) |
| worker_snippets | Worker Container Linux Config snippets | [] | [example](/advanced/customization/) |
| networking | Choice of networking provider | "calico" | "calico" or "cilium" or "flannel" |
| pod_cidr | CIDR IPv4 range to assign to Kubernetes pods | "10.2.0.0/16" | "10.22.0.0/16" |
| service_cidr | CIDR IPv4 range to assign to Kubernetes services | "10.3.0.0/16" | "10.3.0.0/24" |
| worker_node_labels | List of initial worker node labels | [] | ["worker-pool=default"] |

Check the list of valid [machine types](https://cloud.google.com/compute/docs/machine-types).

#### Preemption

Add `worker_preemptible = "true"` to allow worker nodes to be [preempted](https://cloud.google.com/compute/docs/instances/preemptible) at random, but pay [significantly](https://cloud.google.com/compute/pricing) less. Clusters tolerate stopping instances fairly well (reschedules pods, but cannot drain) and preemption provides a nice reward for running fault-tolerant cluster systems.`

