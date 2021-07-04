# Worker Pools

Typhoon AWS, Azure, and Google Cloud allow additional groups of workers to be defined and joined to a cluster. For example, add worker pools of instances with different types, disk sizes, Container Linux channels, or preemptibility modes.

Internal Terraform Modules:

* `aws/flatcar-linux/kubernetes/workers`
* `aws/fedora-coreos/kubernetes/workers`
* `azure/flatcar-linux/kubernetes/workers`
* `azure/fedora-coreos/kubernetes/workers`
* `google-cloud/flatcar-linux/kubernetes/workers`
* `google-cloud/fedora-coreos/kubernetes/workers`

## AWS

Create a cluster following the AWS [tutorial](../flatcar-linux/aws.md#cluster). Define a worker pool using the AWS internal `workers` module.

=== "Fedora CoreOS"

    ```tf
    module "tempest-worker-pool" {
      source = "git::https://github.com/poseidon/typhoon//aws/fedora-coreos/kubernetes/workers?ref=v1.21.2"

      # AWS
      vpc_id          = module.tempest.vpc_id
      subnet_ids      = module.tempest.subnet_ids
      security_groups = module.tempest.worker_security_groups

      # configuration
      name               = "tempest-pool"
      kubeconfig         = module.tempest.kubeconfig
      ssh_authorized_key = var.ssh_authorized_key

      # optional
      worker_count  = 2
      instance_type = "m5.large"
      os_stream     = "next"
    }
    ```

=== "Flatcar Linux"

    ```tf
    module "tempest-worker-pool" {
      source = "git::https://github.com/poseidon/typhoon//aws/flatcar-linux/kubernetes/workers?ref=v1.21.2"

      # AWS
      vpc_id          = module.tempest.vpc_id
      subnet_ids      = module.tempest.subnet_ids
      security_groups = module.tempest.worker_security_groups

      # configuration
      name               = "tempest-pool"
      kubeconfig         = module.tempest.kubeconfig
      ssh_authorized_key = var.ssh_authorized_key

      # optional
      worker_count  = 2
      instance_type = "m5.large"
      os_image      = "flatcar-beta"
    }
    ```

Apply the change.

```
terraform apply
```

Verify an auto-scaling group of workers joins the cluster within a few minutes.

### Variables

The AWS internal `workers` module supports a number of [variables](https://github.com/poseidon/typhoon/blob/master/aws/flatcar-linux/kubernetes/workers/variables.tf).

#### Required

| Name | Description | Example |
|:-----|:------------|:--------|
| name | Unique name (distinct from cluster name) | "tempest-m5s" |
| vpc_id | Must be set to `vpc_id` output by cluster | module.cluster.vpc_id |
| subnet_ids | Must be set to `subnet_ids` output by cluster | module.cluster.subnet_ids |
| security_groups | Must be set to `worker_security_groups` output by cluster | module.cluster.worker_security_groups |
| kubeconfig | Must be set to `kubeconfig` output by cluster | module.cluster.kubeconfig |
| ssh_authorized_key | SSH public key for user 'core' | "ssh-rsa AAAAB3NZ..." |

#### Optional

| Name | Description | Default | Example |
|:-----|:------------|:--------|:--------|
| worker_count | Number of instances | 1 | 3 |
| instance_type | EC2 instance type | "t3.small" | "t3.medium" |
| os_image | AMI channel for a Container Linux derivative | "flatcar-stable" | flatcar-stable, flatcar-beta, flatcar-alpha |
| os_stream | Fedora CoreOS stream for compute instances | "stable" | "testing", "next" |
| disk_size | Size of the EBS volume in GB | 40 | 100 |
| disk_type | Type of the EBS volume | "gp3" | standard, gp2, gp3, io1 |
| disk_iops | IOPS of the EBS volume | 0 (i.e. auto) | 400 |
| spot_price | Spot price in USD for worker instances or 0 to use on-demand instances | 0 | 0.10 |
| snippets | Fedora CoreOS or Container Linux Config snippets | [] | [examples](/advanced/customization/) |
| service_cidr | Must match `service_cidr` of cluster | "10.3.0.0/16" | "10.3.0.0/24" |
| node_labels | List of initial node labels | [] | ["worker-pool=foo"] |
| node_taints | List of initial node taints | [] | ["role=gpu:NoSchedule"] |

Check the list of valid [instance types](https://aws.amazon.com/ec2/instance-types/) or per-region and per-type [spot prices](https://aws.amazon.com/ec2/spot/pricing/).

## Azure

Create a cluster following the Azure [tutorial](../flatcar-linux/azure.md#cluster). Define a worker pool using the Azure internal `workers` module.

=== "Fedora CoreOS"

    ```tf
    module "ramius-worker-pool" {
      source = "git::https://github.com/poseidon/typhoon//azure/fedora-coreos/kubernetes/workers?ref=v1.21.2"

      # Azure
      region                  = module.ramius.region
      resource_group_name     = module.ramius.resource_group_name
      subnet_id               = module.ramius.subnet_id
      security_group_id       = module.ramius.security_group_id
      backend_address_pool_id = module.ramius.backend_address_pool_id

      # configuration
      name               = "ramius-spot"
      kubeconfig         = module.ramius.kubeconfig
      ssh_authorized_key = var.ssh_authorized_key

      # optional
      worker_count = 2
      vm_type      = "Standard_F4"
      priority     = "Spot"
      os_image     = "/subscriptions/some/path/Microsoft.Compute/images/fedora-coreos-31.20200323.3.2"
    }
    ```

=== "Flatcar Linux"

    ```tf
    module "ramius-worker-pool" {
      source = "git::https://github.com/poseidon/typhoon//azure/flatcar-linux/kubernetes/workers?ref=v1.21.2"

      # Azure
      region                  = module.ramius.region
      resource_group_name     = module.ramius.resource_group_name
      subnet_id               = module.ramius.subnet_id
      security_group_id       = module.ramius.security_group_id
      backend_address_pool_id = module.ramius.backend_address_pool_id

      # configuration
      name               = "ramius-spot"
      kubeconfig         = module.ramius.kubeconfig
      ssh_authorized_key = var.ssh_authorized_key

      # optional
      worker_count = 2
      vm_type      = "Standard_F4"
      priority     = "Spot"
      os_image     = "flatcar-beta"
    }
    ```

Apply the change.

```
terraform apply
```

Verify a scale set of workers joins the cluster within a few minutes.

### Variables

The Azure internal `workers` module supports a number of [variables](https://github.com/poseidon/typhoon/blob/master/azure/flatcar-linux/kubernetes/workers/variables.tf).

#### Required

| Name | Description | Example |
|:-----|:------------|:--------|
| name | Unique name (distinct from cluster name) | "ramius-f4" |
| region | Must be set to `region` output by cluster | module.cluster.region |
| resource_group_name | Must be set to `resource_group_name` output by cluster | module.cluster.resource_group_name |
| subnet_id | Must be set to `subnet_id` output by cluster | module.cluster.subnet_id |
| security_group_id | Must be set to `security_group_id` output by cluster | module.cluster.security_group_id |
| backend_address_pool_id | Must be set to `backend_address_pool_id` output by cluster | module.cluster.backend_address_pool_id |
| kubeconfig | Must be set to `kubeconfig` output by cluster | module.cluster.kubeconfig |
| ssh_authorized_key | SSH public key for user 'core' | "ssh-rsa AAAAB3NZ..." |

#### Optional

| Name | Description | Default | Example |
|:-----|:------------|:--------|:--------|
| worker_count | Number of instances | 1 | 3 |
| vm_type | Machine type for instances | "Standard_DS1_v2" | See below |
| os_image | Channel for a Container Linux derivative | "flatcar-stable" | flatcar-stable, flatcar-beta, flatcar-alpha |
| priority | Set priority to Spot to use reduced cost surplus capacity, with the tradeoff that instances can be deallocated at any time | "Regular" | "Spot" |
| snippets | Container Linux Config snippets | [] | [examples](/advanced/customization/) |
| service_cidr | CIDR IPv4 range to assign to Kubernetes services | "10.3.0.0/16" | "10.3.0.0/24" |
| node_labels | List of initial node labels | [] | ["worker-pool=foo"] |
| node_taints | List of initial node taints | [] | ["role=gpu:NoSchedule"] |

Check the list of valid [machine types](https://azure.microsoft.com/en-us/pricing/details/virtual-machines/linux/) and their [specs](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/sizes-general). Use `az vm list-skus` to get the identifier.

## Google Cloud

Create a cluster following the Google Cloud [tutorial](../flatcar-linux/google-cloud.md#cluster). Define a worker pool using the Google Cloud internal `workers` module.

=== "Fedora CoreOS"

    ```tf
    module "yavin-worker-pool" {
      source = "git::https://github.com/poseidon/typhoon//google-cloud/fedora-coreos/kubernetes/workers?ref=v1.21.2"

      # Google Cloud
      region       = "europe-west2"
      network      = module.yavin.network_name
      cluster_name = "yavin"

      # configuration
      name               = "yavin-16x"
      kubeconfig         = module.yavin.kubeconfig
      ssh_authorized_key = var.ssh_authorized_key

      # optional
      worker_count = 2
      machine_type = "n1-standard-16"
      os_stream    = "testing"
      preemptible  = true
    }
    ```

=== "Flatcar Linux"

    ```tf
    module "yavin-worker-pool" {
      source = "git::https://github.com/poseidon/typhoon//google-cloud/flatcar-linux/kubernetes/workers?ref=v1.21.2"

      # Google Cloud
      region       = "europe-west2"
      network      = module.yavin.network_name
      cluster_name = "yavin"

      # configuration
      name               = "yavin-16x"
      kubeconfig         = module.yavin.kubeconfig
      ssh_authorized_key = var.ssh_authorized_key

      # optional
      worker_count = 2
      machine_type = "n1-standard-16"
      os_image     = "flatcar-linux-2303-4-0"    # custom
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
yavin-controller-0.c.example-com.internal        Ready    6m     v1.21.2
yavin-worker-jrbf.c.example-com.internal         Ready    5m     v1.21.2
yavin-worker-mzdm.c.example-com.internal         Ready    5m     v1.21.2
yavin-16x-worker-jrbf.c.example-com.internal     Ready    3m     v1.21.2
yavin-16x-worker-mzdm.c.example-com.internal     Ready    3m     v1.21.2
```

### Variables

The Google Cloud internal `workers` module supports a number of [variables](https://github.com/poseidon/typhoon/blob/master/google-cloud/flatcar-linux/kubernetes/workers/variables.tf).

#### Required

| Name | Description | Example |
|:-----|:------------|:--------|
| name | Unique name (distinct from cluster name) | "yavin-16x" |
| cluster_name | Must be set to `cluster_name` of cluster | "yavin" |
| region | Region for the worker pool instances. May differ from the cluster's region | "europe-west2" |
| network | Must be set to `network_name` output by cluster | module.cluster.network_name |
| kubeconfig | Must be set to `kubeconfig` output by cluster | module.cluster.kubeconfig |
| os_image | Container Linux image for compute instances | "uploaded-flatcar-image" |
| ssh_authorized_key | SSH public key for user 'core' | "ssh-rsa AAAAB3NZ..." |

Check the list of regions [docs](https://cloud.google.com/compute/docs/regions-zones/regions-zones) or with `gcloud compute regions list`.

#### Optional

| Name | Description | Default | Example |
|:-----|:------------|:--------|:--------|
| worker_count | Number of instances | 1 | 3 |
| machine_type | Compute instance machine type | "n1-standard-1" | See below |
| os_stream | Fedora CoreOS stream for compute instances | "stable" | "testing", "next" |
| disk_size | Size of the disk in GB | 40 | 100 |
| preemptible | If true, Compute Engine will terminate instances randomly within 24 hours | false | true |
| snippets | Container Linux Config snippets | [] | [examples](/advanced/customization/) |
| service_cidr | Must match `service_cidr` of cluster | "10.3.0.0/16" | "10.3.0.0/24" |
| node_labels | List of initial node labels | [] | ["worker-pool=foo"] |
| node_taints | List of initial node taints | [] | ["role=gpu:NoSchedule"] |

Check the list of valid [machine types](https://cloud.google.com/compute/docs/machine-types).

