# Customization

Typhoon provides Kubernetes clusters with defaults recommended for production. Terraform variables expose supported customization options. Advanced options are available for customizing the architecture or hosts as well.

## Variables

Typhoon modules accept Terraform input variables for customizing clusters in meritorious ways (e.g. `worker_count`, etc). Variables are carefully considered to provide essentials, while limiting complexity and test matrix burden. See each platform's tutorial for options.

## Addons

Clusters are kept to a minimal Kubernetes control plane by offering components like Nginx Ingress Controller, Prometheus, Grafana, and Heapster as optional post-install [addons](https://github.com/poseidon/typhoon/tree/master/addons). Customize addons by modifying a copy of our addon manifests.

## Hosts

### Container Linux

!!! danger
    Container Linux Configs provide powerful host customization abilities. You are responsible for the additional configs defined for hosts.

Container Linux Configs (CLCs) declare how a Container Linux instance's disk should be provisioned on first boot from disk. CLCs define disk partitions, filesystems, files, systemd units, dropins, networkd configs, mount units, raid arrays, and users. Typhoon creates controller and worker instances with base Container Linux Configs to create a minimal, secure Kubernetes cluster on each platform.

Typhoon AWS, Azure, bare-metal, DigitalOcean, and Google Cloud support CLC *snippets* - valid Container Linux Configs that are validated and additively merged into the Typhoon base config during `terraform plan`. This allows advanced host customizations and experimentation.

#### Examples

Container Linux [docs](https://coreos.com/os/docs/latest/clc-examples.html) show many simple config examples. Ensure a file `/opt/hello` is created with permissions 0644. 

```
# custom-files
storage:
  files:
    - path: /opt/hello
      filesystem: root
      contents:
        inline: |
          Hello World
      mode: 0644
```

Ensure a systemd unit `hello.service` is created and a dropin `50-etcd-cluster.conf` is added for `etcd-member.service`.

```
# custom-units
systemd:
  units:
    - name: hello.service
      enable: true
      contents: |
        [Unit]
        Description=Hello World
        [Service]
        Type=oneshot
        ExecStart=/usr/bin/echo Hello World!
        [Install]
        WantedBy=multi-user.target
    - name: etcd-member.service
      enable: true
      dropins:
        - name: 50-etcd-cluster.conf
          contents: |
            Environment="ETCD_LOG_PACKAGE_LEVELS=etcdserver=WARNING,security=DEBUG"
```

#### Specification

View the Container Linux Config [format](https://coreos.com/os/docs/1576.4.0/configuration.html) to read about each field.

#### Usage

Write Container Linux Configs *snippets* as files in the repository where you keep Terraform configs for clusters (perhaps in a `clc` or `snippets` subdirectory). You may organize snippets in multiple files as desired, provided they are each valid.

[AWS](/cl/aws/#cluster), [Azure](/cl/azure/#cluster), [DigitalOcean](/cl/digital-ocean/#cluster), and [Google Cloud](/cl/google-cloud/#cluster) clusters allow populating a list of `controller_clc_snippets` or `worker_clc_snippets`.

```
module "digital-ocean-nemo" {
  ...

  controller_count        = 1
  worker_count            = 2
  controller_clc_snippets = [
    "${file("./custom-files")}",
    "${file("./custom-units")}",
  ]
  worker_clc_snippets = [
    "${file("./custom-files")}",
    "${file("./custom-units")}",
  ]
  ...
}
```

[Bare-Metal](/cl/bare-metal/#cluster) clusters allow different Container Linux snippets to be used for each node (since hardware may be heterogeneous). Populate the optional `clc_snippets` map variable with any controller or worker name keys and lists of snippets.

```
module "bare-metal-mercury" {
  ...
  controller_names = ["node1"]
  worker_names = [
    "node2",
    "node3",
  ]
  clc_snippets = {
    "node2" = [
      "${file("./units/hello.yaml")}"
    ]
    "node3" = [
      "${file("./units/world.yaml")}",
      "${file("./units/hello.yaml")}",
    ]
  }
  ...
}
```

Plan the resources to be created.

```
$ terraform plan
Plan: 54 to add, 0 to change, 0 to destroy.
```

Most syntax errors in CLCs can be caught during planning. For example, mangle the indentation in one of the CLC files:

```
$ terraform plan
...
error parsing Container Linux Config: error: yaml: line 3: did not find expected '-' indicator
```

Undo the mangle. Apply the changes to create the cluster per the tutorial.

```
$ terraform apply
```

Container Linux Configs (and the CoreOS Ignition system) create immutable infrastructure. Disk provisioning is performed only on first boot from disk. That means if you change a snippet used by an instance, Terraform will (correctly) try to destroy and recreate that instance. Be careful!

!!! danger
    Destroying and recreating controller instances is destructive! etcd runs on controller instances and stores data there. Do not modify controller snippets. See [blue/green](/topics/maintenance/#upgrades) clusters.

### Fedora Atomic

Cloud-Init and kickstart (bare-metal only) declare how a Fedora Atomic instance should be provisioned. Customizing these declarations in ways beyond the provided Terraform variables is unsupported.

## Architecture

Typhoon chooses variables to expose with purpose. If you must customize clusters in ways that aren't supported by input variables, fork Typhoon and maintain a repository with customizations. Reference the repository by changing the username.

```
module "digital-ocean-nemo" {
  source = "git::https://github.com/USERNAME/typhoon//digital-ocean/container-linux/kubernetes?ref=myspecialcase"
  ...
}
```

To customize lower-level Kubernetes control plane bootstrapping, see the [poseidon/terraform-render-bootkube](https://github.com/poseidon/terraform-render-bootkube) Terraform module.

