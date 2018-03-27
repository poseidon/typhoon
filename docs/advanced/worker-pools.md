# Worker Pools

Typhoon AWS and Google Cloud allow additional groups of workers to be defined and joined to a cluster. For example, add worker pools of instances with different types, disk sizes, Container Linux channels, or preemptibility modes.

Internal Terraform Modules:

* `aws/container-linux/kubernetes/workers`
* `google-cloud/container-linux/kubernetes/workers`

## AWS

Create a cluster following the AWS [tutorial](../aws.md#cluster). Define a worker pool using the AWS internal `workers` module.

```tf
module "tempest-worker-pool" {
  source = "git::https://github.com/poseidon/typhoon//aws/container-linux/kubernetes/workers?ref=v1.10.0"
  
  providers = {
    aws = "aws.default"
  }

  # AWS
  vpc_id          = "${module.aws-tempest.vpc_id}"
  subnet_ids      = "${module.aws-tempest.subnet_ids}"
  security_groups = "${module.aws-tempest.worker_security_groups}"
  
  # configuration
  name               = "tempest-worker-pool"
  kubeconfig         = "${module.aws-tempest.kubeconfig}"
  ssh_authorized_key = "${var.ssh_authorized_key}"

  count         = 2
  instance_type = "m5.large"
  os_channel    = "beta"    
}
```

Apply the change.

```
terraform apply
```

Verify an auto-scaling group of workers join the cluster within a few minutes.

### Variables

The AWS internal `workers` module supports a number of [variables](https://github.com/poseidon/typhoon/blob/master/aws/container-linux/kubernetes/workers/variables.tf).

#### Required

| Name | Description | Example |
|:-----|:------------|:--------|
| vpc_id | Must be set to `vpc_id` output by cluster | "${module.cluster.vpc_id}" |
| subnet_ids | Must be set to `subnet_ids` output by cluster | "${module.cluster.subnet_ids}" |
| security_groups | Must be set to `worker_security_groups` output by cluster | "${module.cluster.worker_security_groups}" |
| name | Unique name (distinct from cluster name) | "tempest-m5s" |
| kubeconfig | Must be set to `kubeconfig` output by cluster | "${module.cluster.kubeconfig}" |
| ssh_authorized_key | SSH public key for user 'core' | "ssh-rsa AAAAB3NZ..." |

#### Optional

| Name | Description | Default | Example |
|:-----|:------------|:--------|:--------|
| count | Number of instances | 1 | 3 |
| instance_type | EC2 instance type | "t2.small" | "t2.medium" |
| os_channel | Container Linux AMI channel | stable| "beta", "alpha" |
| disk_size | Size of the disk in GB | 40 | 100 |
| service_cidr | Must match `service_cidr` of cluster | "10.3.0.0/16" | "10.3.0.0/24" |
| cluster_domain_suffix | Must match `cluster_domain_suffix` of cluster | "cluster.local" | "k8s.example.com" |

Check the list of valid [instance types](https://aws.amazon.com/ec2/instance-types/).

## Google Cloud

Create a cluster following the Google Cloud [tutorial](../google-cloud.md#cluster). Define a worker pool using the Google Cloud internal `workers` module.

```tf
module "yavin-worker-pool" {
  source = "git::https://github.com/poseidon/typhoon//google-cloud/container-linux/kubernetes/workers?ref=v1.10.0"

  providers = {
    google = "google.default"
  }

  # Google Cloud
  region       = "us-central1"
  network      = "${module.google-cloud-yavin.network_name}"
  cluster_name = "yavin"

  # configuration
  name               = "yavin-16x"
  kubeconfig         = "${module.google-cloud-yavin.kubeconfig}"
  ssh_authorized_key = "${var.ssh_authorized_key}"
  
  count        = 2
  machine_type = "n1-standard-16"
  os_image     = "coreos-beta"
  preemptible  = true
}
```

Apply the change.

```
terraform apply
```

Verify a managed instance group of workers joins the cluster within a few minutes.

```
$ kubectl get nodes
NAME                                             STATUS   AGE    VERSION
yavin-controller-0.c.example-com.internal        Ready    6m     v1.10.0
yavin-worker-jrbf.c.example-com.internal         Ready    5m     v1.10.0
yavin-worker-mzdm.c.example-com.internal         Ready    5m     v1.10.0
yavin-16x-worker-jrbf.c.example-com.internal     Ready    3m     v1.10.0
yavin-16x-worker-mzdm.c.example-com.internal     Ready    3m     v1.10.0
```

### Variables

The Google Cloud internal `workers` module supports a number of [variables](https://github.com/poseidon/typhoon/blob/master/google-cloud/container-linux/kubernetes/workers/variables.tf).

#### Required

| Name | Description | Example |
|:-----|:------------|:--------|
| region | Must be set to `region` of cluster | "us-central1" |
| network | Must be set to `network_name` output by cluster | "${module.cluster.network_name}" |
| name | Unique name (distinct from cluster name) | "yavin-16x" |
| cluster_name | Must be set to `cluster_name` of cluster | "yavin" |
| kubeconfig | Must be set to `kubeconfig` output by cluster | "${module.cluster.kubeconfig}" |
| ssh_authorized_key | SSH public key for user 'core' | "ssh-rsa AAAAB3NZ..." |

#### Optional

| Name | Description | Default | Example |
|:-----|:------------|:--------|:--------|
| count | Number of instances | 1 | 3 |
| machine_type | Compute instance machine type | "n1-standard-1" | See below |
| os_image | Container Linux image for compute instances | "coreos-stable" | "coreos-alpha", "coreos-beta" |
| disk_size | Size of the disk in GB | 40 | 100 |
| preemptible | If true, Compute Engine will terminate instances randomly within 24 hours | false | true |
| service_cidr | Must match `service_cidr` of cluster | "10.3.0.0/16" | "10.3.0.0/24" |
| cluster_domain_suffix | Must match `cluster_domain_suffix` of cluster | "cluster.local" | "k8s.example.com" |

Check the list of valid [machine types](https://cloud.google.com/compute/docs/machine-types).

