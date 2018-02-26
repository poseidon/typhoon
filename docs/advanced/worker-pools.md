# Worker Pools

Typhoon can create "worker pools", groups of homogeneous workers that are part of an existing cluster. For example, you may wish to augment a Kubernetes cluster with groups of workers with a different machine type, larger disks, or preemptibility.

## Google Cloud

Create a cluster following the Google Cloud [tutorial](../google-cloud.md#cluster). Then define a worker pool using the internal `workers` Terraform module.

```tf
module "yavin-worker-pool" {
  source = "git::https://github.com/poseidon/typhoon//google-cloud/container-linux/kubernetes/workers?ref=v1.9.4"

  # Google Cloud
  network      = "${module.google-cloud-yavin.network_name}"
  region       = "us-central1"
  count        = 2
  machine_type = "n1-standard-16"
  preemptible  = true

  cluster_name = "yavin-16x"
  ssh_authorized_key = "${var.ssh_authorized_key}"

  kubeconfig = "${module.google-cloud-yavin.kubeconfig}"
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
yavin-controller-0.c.example-com.internal        Ready    6m     v1.9.3
yavin-worker-jrbf.c.example-com.internal         Ready    5m     v1.9.3
yavin-worker-mzdm.c.example-com.internal         Ready    5m     v1.9.3
yavin-16x-worker-jrbf.c.example-com.internal     Ready    3m     v1.9.3
yavin-16x-worker-mzdm.c.example-com.internal     Ready    3m     v1.9.3
```

### Variables

The Google Cloud internal `workers` module supports a number of [variables](https://github.com/poseidon/typhoon/blob/master/google-cloud/container-linux/kubernetes/workers/variables.tf).

#### Required

| Name | Description | Example |
|:-----|:------------|:--------|
| cluster_name | Unique name | "yavin-worker-pool" |
| region | Must match region of cluster | "us-central1" |
| network | Must match network name output by cluster | "${module.cluster.network_name}" |
| ssh_authorized_key | SSH public key for ~/.ssh_authorized_keys | "ssh-rsa AAAAB3NZ..." |

#### Optional

| Name | Description | Default | Example |
|:-----|:------------|:--------|:--------|
| count | Number of workers | 1 | 3 |
| machine_type | Machine type for compute instances | "n1-standard-1" | See below |
| os_image | OS image for compute instances | "coreos-stable" | "coreos-alpha" |
| disk_size | Size of the disk in GB | 40 | 100 |
| preemptible | If enabled, Compute Engine will terminate instances randomly within 24 hours | false | true |
| service_cidr | Must match service_cidr of cluster | "10.3.0.0/16" | "10.3.0.0/24" |
| cluster_domain_suffix | Must match domain suffix of cluster | "cluster.local" | "k8s.example.com" |

Check the list of valid [machine types](https://cloud.google.com/compute/docs/machine-types).

