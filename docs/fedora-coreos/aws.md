# AWS

!!! danger
    Typhoon for Fedora CoreOS is an early preview! Fedora CoreOS itself is a preview! Expect bugs and design shifts. Please help both projects solve problems. Report Fedora CoreOS bugs to [Fedora](https://github.com/coreos/fedora-coreos-tracker/issues). Report Typhoon issues to Typhoon.

In this tutorial, we'll create a Kubernetes v1.16.3 cluster on AWS with Fedora CoreOS.

We'll declare a Kubernetes cluster using the Typhoon Terraform module. Then apply the changes to create a VPC, gateway, subnets, security groups, controller instances, worker auto-scaling group, network load balancer, and TLS assets.

Controller hosts are provisioned to run an `etcd-member` peer and a `kubelet` service. Worker hosts run a `kubelet` service. Controller nodes run `kube-apiserver`, `kube-scheduler`, `kube-controller-manager`, and `coredns`, while `kube-proxy` and `calico` (or `flannel`) run on every node. A generated `kubeconfig` provides `kubectl` access to the cluster.

## Requirements

* AWS Account and IAM credentials
* AWS Route53 DNS Zone (registered Domain Name or delegated subdomain)
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

Login to your AWS IAM dashboard and find your IAM user. Select "Security Credentials" and create an access key. Save the id and secret to a file that can be referenced in configs.

```
[default]
aws_access_key_id = xxx
aws_secret_access_key = yyy
```

Configure the AWS provider to use your access key credentials in a `providers.tf` file.

```tf
provider "aws" {
  version                 = "2.35.0"
  region                  = "eu-central-1"
  shared_credentials_file = "/home/user/.config/aws/credentials"
}

provider "ct" {
  version = "0.4.0"
}
```

Additional configuration options are described in the `aws` provider [docs](https://www.terraform.io/docs/providers/aws/).

!!! tip
    Regions are listed in [docs](http://docs.aws.amazon.com/general/latest/gr/rande.html#ec2_region) or with `aws ec2 describe-regions`.

## Cluster

Define a Kubernetes cluster using the module `aws/fedora-coreos/kubernetes`.

```tf
module "aws-tempest" {
  source = "git::https://github.com/poseidon/typhoon//aws/fedora-coreos/kubernetes?ref=v1.16.3"

  # AWS
  cluster_name = "tempest"
  dns_zone     = "aws.example.com"
  dns_zone_id  = "Z3PAABBCFAKEC0"

  # configuration
  ssh_authorized_key = "ssh-rsa AAAAB3Nz..."
  asset_dir          = "/home/user/.secrets/clusters/tempest"

  # optional
  worker_count = 2
  worker_type  = "t3.small"
}
```

Reference the [variables docs](#variables) or the [variables.tf](https://github.com/poseidon/typhoon/blob/master/aws/fedora-coreos/kubernetes/variables.tf) source.

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
Plan: 98 to add, 0 to change, 0 to destroy.
```

Apply the changes to create the cluster.

```sh
$ terraform apply
...
module.aws-tempest.null_resource.bootstrap: Still creating... (4m50s elapsed)
module.aws-tempest.null_resource.bootstrap: Still creating... (5m0s elapsed)
module.aws-tempest.null_resource.bootstrap: Creation complete after 5m8s (ID: 3961816482286168143)

Apply complete! Resources: 98 added, 0 changed, 0 destroyed.
```

In 4-8 minutes, the Kubernetes cluster will be ready.

## Verify

[Install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) on your system. Use the generated `kubeconfig` credentials to access the Kubernetes cluster and list nodes.

```
$ export KUBECONFIG=/home/user/.secrets/clusters/tempest/auth/kubeconfig
$ kubectl get nodes
NAME           STATUS  ROLES    AGE  VERSION
ip-10-0-3-155  Ready   <none>   10m  v1.16.3
ip-10-0-26-65  Ready   <none>   10m  v1.16.3
ip-10-0-41-21  Ready   <none>   10m  v1.16.3
```

List the pods.

```
$ kubectl get pods --all-namespaces
NAMESPACE     NAME                                   READY  STATUS    RESTARTS  AGE
kube-system   calico-node-1m5bf                      2/2    Running   0         34m
kube-system   calico-node-7jmr1                      2/2    Running   0         34m
kube-system   calico-node-bknc8                      2/2    Running   0         34m
kube-system   coredns-1187388186-wx1lg               1/1    Running   0         34m
kube-system   coredns-1187388186-qjnvp               1/1    Running   0         34m
kube-system   kube-apiserver-ip-10-0-3-155           1/1    Running   0         34m
kube-system   kube-controller-manager-ip-10-0-3-155  1/1    Running   0         34m
kube-system   kube-proxy-14wxv                       1/1    Running   0         34m
kube-system   kube-proxy-9vxh2                       1/1    Running   0         34m
kube-system   kube-proxy-sbbsh                       1/1    Running   0         34m
kube-system   kube-scheduler-ip-10-0-3-155           1/1    Running   1         34m
```

## Going Further

Learn about [maintenance](/topics/maintenance/) and [addons](/addons/overview/).

## Variables

Check the [variables.tf](https://github.com/poseidon/typhoon/blob/master/aws/fedora-coreos/kubernetes/variables.tf) source.

### Required

| Name | Description | Example |
|:-----|:------------|:--------|
| cluster_name | Unique cluster name (prepended to dns_zone) | "tempest" |
| dns_zone | AWS Route53 DNS zone | "aws.example.com" |
| dns_zone_id | AWS Route53 DNS zone id | "Z3PAABBCFAKEC0" |
| ssh_authorized_key | SSH public key for user 'core' | "ssh-rsa AAAAB3NZ..." |
| asset_dir | Absolute path to a directory where generated assets should be placed (contains secrets) | "/home/user/.secrets/clusters/tempest" |

#### DNS Zone

Clusters create a DNS A record `${cluster_name}.${dns_zone}` to resolve a network load balancer backed by controller instances. This FQDN is used by workers and `kubectl` to access the apiserver(s). In this example, the cluster's apiserver would be accessible at `tempest.aws.example.com`.

You'll need a registered domain name or delegated subdomain on AWS Route53. You can set this up once and create many clusters with unique names.

```tf
resource "aws_route53_zone" "zone-for-clusters" {
  name = "aws.example.com."
}
```

Reference the DNS zone id with `aws_route53_zone.zone-for-clusters.zone_id`.

!!! tip ""
    If you have an existing domain name with a zone file elsewhere, just delegate a subdomain that can be managed on Route53 (e.g. aws.mydomain.com) and [update nameservers](http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/SOA-NSrecords.html).

### Optional

| Name | Description | Default | Example |
|:-----|:------------|:--------|:--------|
| controller_count | Number of controllers (i.e. masters) | 1 | 1 |
| worker_count | Number of workers | 1 | 3 |
| controller_type | EC2 instance type for controllers | "t3.small" | See below |
| worker_type | EC2 instance type for workers | "t3.small" | See below |
| os_image | AMI channel for Fedora CoreOS | not yet used | ? |
| disk_size | Size of the EBS volume in GB | 40 | 100 |
| disk_type | Type of the EBS volume | "gp2" | standard, gp2, io1 |
| disk_iops | IOPS of the EBS volume | 0 (i.e. auto) | 400 |
| worker_target_groups | Target group ARNs to which worker instances should be added | [] | [aws_lb_target_group.app.id] |
| worker_price | Spot price in USD for worker instances or 0 to use on-demand instances | 0 | 0.10 |
| controller_snippets | Controller Fedora CoreOS Config snippets | [] | UNSUPPORTED |
| worker_clc_snippets | Worker Fedora CoreOS Config snippets | [] | UNSUPPORTED |
| networking | Choice of networking provider | "calico" | "calico" or "flannel" |
| network_mtu | CNI interface MTU (calico only) | 1480 | 8981 |
| host_cidr | CIDR IPv4 range to assign to EC2 instances | "10.0.0.0/16" | "10.1.0.0/16" |
| pod_cidr | CIDR IPv4 range to assign to Kubernetes pods | "10.2.0.0/16" | "10.22.0.0/16" |
| service_cidr | CIDR IPv4 range to assign to Kubernetes services | "10.3.0.0/16" | "10.3.0.0/24" |
| worker_node_labels | List of initial worker node labels | [] | ["worker-pool=default"] |

Check the list of valid [instance types](https://aws.amazon.com/ec2/instance-types/).

!!! warning
    Do not choose a `controller_type` smaller than `t2.small`. Smaller instances are not sufficient for running a controller.

!!! tip "MTU"
    If your EC2 instance type supports [Jumbo frames](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/network_mtu.html#jumbo_frame_instances) (most do), we recommend you change the `network_mtu` to 8981! You will get better pod-to-pod bandwidth.

#### Spot

Add `worker_price = "0.10"` to use spot instance workers (instead of "on-demand") and set a maximum spot price in USD. Clusters can tolerate spot market interuptions fairly well (reschedules pods, but cannot drain) to save money, with the tradeoff that requests for workers may go unfulfilled.

