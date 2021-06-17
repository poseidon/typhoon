# Nodes

Typhoon clusters consist of controller node(s) and a (default) set of worker nodes.

## Overview

Typhoon nodes use the standard set of Kubernetes node labels.

```yaml
Labels: kubernetes.io/arch=amd64
        kubernetes.io/hostname=node-name
        kubernetes.io/os=linux
```

Controller node(s) are labeled to allow node selection (for rare components that run on controllers) and tainted to prevent ordinary workloads running on controllers.

```yaml
Labels: node.kubernetes.io/controller=true
Taints: node-role.kubernetes.io/controller:NoSchedule
```

Worker nodes are labeled to allow node selection and untainted. Workloads will schedule on worker nodes by default, baring any contraindications.

```yaml
Labels: node.kubernetes.io/node=
Taints: <none>
```

On auto-scaling cloud platforms, you may add [worker pools](/advanced/worker-pools/) with different groups of nodes with their own labels and taints. On platforms like bare-metal, with heterogeneous machines, you may manage node labels and taints per node.

## Node Labels

Add custom initial worker node labels to default workers or worker pool nodes to allow workloads to select among nodes that differ.

=== "Cluster"

    ```tf
    module "yavin" {
      source = "git::https://github.com/poseidon/typhoon//google-cloud/fedora-coreos/kubernetes?ref=v1.21.2"

      # Google Cloud
      cluster_name  = "yavin"
      region        = "us-central1"
      dns_zone      = "example.com"
      dns_zone_name = "example-zone"

      # configuration
      ssh_authorized_key = local.ssh_key

      # optional
      worker_count = 2
      worker_node_labels = ["pool=default"]
    }
    ```

=== "Worker Pool"

    ```tf
    module "yavin-pool" {
      source = "git::https://github.com/poseidon/typhoon//google-cloud/fedora-coreos/kubernetes/workers?ref=v1.21.2"

      # Google Cloud
      cluster_name = "yavin"
      region       = "europe-west2"
      network      = module.yavin.network_name

      # configuration
      name               = "yavin-16x"
      kubeconfig         = module.yavin.kubeconfig
      ssh_authorized_key = local.ssh_key

      # optional
      worker_count = 1
      machine_type = "n1-standard-16"
      node_labels  = ["pool=big"]
    }
    ```

In the example above, the two default workers would be labeled `pool: default` and the additional worker would be labeled `pool: big`.

## Node Taints

Add custom initial taints on worker pool nodes to indicate a node is unique and should only schedule workloads that explicitly tolerate a given taint key.

!!! warning
    Since taints prevent workloads scheduling onto a node, you must decide whether `kube-system` DaemonSets (e.g. flannel, Calico, Cilium) should tolerate your custom taint by setting `daemonset_tolerations`. If you don't list your custom taint(s), important components won't run on these nodes.

=== "Cluster"

    ```tf
    module "yavin" {
      source = "git::https://github.com/poseidon/typhoon//google-cloud/fedora-coreos/kubernetes?ref=v1.21.2"

      # Google Cloud
      cluster_name  = "yavin"
      region        = "us-central1"
      dns_zone      = "example.com"
      dns_zone_name = "example-zone"

      # configuration
      ssh_authorized_key = local.ssh_key

      # optional
      worker_count = 2
      daemonset_tolerations = ["role"]
    }
    ```

=== "Worker Pool"

    ```tf
    module "yavin-pool" {
      source = "git::https://github.com/poseidon/typhoon//google-cloud/fedora-coreos/kubernetes/workers?ref=v1.21.2"

      # Google Cloud
      cluster_name = "yavin"
      region       = "europe-west2"
      network      = module.yavin.network_name

      # configuration
      name               = "yavin-16x"
      kubeconfig         = module.yavin.kubeconfig
      ssh_authorized_key = local.ssh_key

      # optional
      worker_count      = 1
      accelerator_type  = "nvidia-tesla-p100"
      accelerator_count = 1
      node_taints       = ["role=gpu:NoSchedule"]
    }
    ```

In the example above, the the additional worker would be tainted with `role=gpu:NoSchedule` to prevent workloads scheduling, but `kube-system` components like flannel, Calico, or Cilium would tolerate that custom taint to run there.

