# Customization

Typhoon provides Kubernetes clusters with defaults recommended for production. Terraform variables expose supported customization options. Advanced options are available for customizing the architecture or hosts as well.

## Variables

Typhoon modules accept Terraform input variables for customizing clusters in meritorious ways (e.g. `worker_count`, etc). Variables are carefully considered to provide essentials, while limiting complexity and test matrix burden. See each platform's tutorial for options.

## Addons

Clusters are kept to a minimal Kubernetes control plane by offering components like Nginx Ingress Controller, Prometheus, and Grafana as optional post-install [addons](https://github.com/poseidon/typhoon/tree/master/addons). Customize addons by modifying a copy of our addon manifests.

## Hosts

### Background

Typhoon uses the [Ignition](https://github.com/coreos/ignition) system of Fedora CoreOS and Flatcar Linux to immutably declare a system via first-boot disk provisioning. Human-friendly [Butane Configs](https://coreos.github.io/butane/specs/) define disk partitions, filesystems, systemd units, dropins, config files, mount units, raid arrays, users, and more before being converted to Ignition.

Controller and worker instances form a minimal and secure Kubernetes cluster on each platform. Typhoon provides the **snippets** feature to accept custom Butane Configs that are merged with instance declarations. This allows advanced host customization and experimentation.

!!! note
    Snippets cannot be used to modify an already existing instance, the antithesis of immutable provisioning. Ignition fully declares a system on first boot only.

!!! danger
    Snippets provide the powerful host customization abilities of Ignition. You are responsible for additional units, configs, files, and conflicts.

!!! danger
    Edits to snippets for controller instances can (correctly) cause Terraform to observe a diff (if not otherwise suppressed) and propose destroying and recreating controller(s). Recognize that this is destructive since controllers run etcd and are stateful. See [blue/green](/topics/maintenance/#upgrades) clusters.

### Usage

Define a Butane Config ([docs](https://coreos.github.io/butane/specs/), [config](https://github.com/coreos/butane/blob/main/docs/config-fcos-v1_4.md)) in version control near your Terraform workspace directory (e.g. perhaps in a `snippets` subdirectory). You may organize snippets into multiple files, if desired.

For example, ensure an `/opt/hello` file is created with permissions 0644 before boot.

=== "Fedora CoreOS"

    ```yaml
    # custom-files.yaml
    variant: fcos
    version: 1.4.0
    storage:
      files:
        - path: /opt/hello
          contents:
            inline: |
              Hello World
          mode: 0644
    ```

=== "Flatcar Linux"

    ```yaml
    # custom-files.yaml
    variant: flatcar
    version: 1.0.0
    storage:
      files:
        - path: /opt/hello
          contents:
            inline: |
              Hello World
          mode: 0644
    ```

Or ensure a systemd unit `hello.service` is created.

=== "Fedora CoreOS"

    ```yaml
    # custom-units.yaml
    variant: fcos
    version: 1.4.0
    systemd:
      units:
        - name: hello.service
          enabled: true
          contents: |
            [Unit]
            Description=Hello World
            [Service]
            Type=oneshot
            ExecStart=/usr/bin/echo Hello World!
            [Install]
            WantedBy=multi-user.target
    ```

=== "Flatcar Linux"

    ```yaml
    # custom-units.yaml
    variant: flatcar
    version: 1.0.0
    systemd:
      units:
        - name: hello.service
          enabled: true
          contents: |
            [Unit]
            Description=Hello World
            [Service]
            Type=oneshot
            ExecStart=/usr/bin/echo Hello World!
            [Install]
            WantedBy=multi-user.target
    ```

Reference the Butane contents by location (e.g. `file("./custom-units.yaml")`). On [AWS](/fedora-coreos/aws/#cluster), [Azure](/fedora-coreos/azure/#cluster), [DigitalOcean](/fedora-coreos/digital-ocean/#cluster), or [Google Cloud](/fedora-coreos/google-cloud/#cluster) extend the `controller_snippets` or `worker_snippets` list variables.


```tf
module "nemo" {
  ...
  worker_count            = 2
  controller_snippets = [
    file("./custom-files.yaml"),
    file("./custom-units.yaml"),
  ]
  worker_snippets = [
    file("./custom-files.yaml"),
    file("./custom-units.yaml")",
  ]
  ...
}
```

On [Bare-Metal](/fedora-coreos/bare-metal/#cluster), different Butane configs may be used for each node (since hardware may be heterogeneous). Extend the `snippets` map variable by mapping a controller or worker name key to a list of snippets.

```tf
module "mercury" {
  ...
  snippets = {
    "node2" = [file("./units/hello.yaml")]
    "node3" = [
      file("./units/world.yaml"),
      file("./units/hello.yaml"),
    ]
  }
  ...
}
```

## Architecture

Typhoon chooses variables to expose with purpose. If you must customize clusters in ways that aren't supported by input variables, fork Typhoon and maintain a repository with customizations. Reference the repository by changing the username.

```
module "nemo" {
  source = "git::https://github.com/USERNAME/typhoon//digital-ocean/flatcar-linux/kubernetes?ref=myspecialcase"
  ...
}
```

To customize low-level Kubernetes control plane bootstrapping, see the [poseidon/terraform-render-bootstrap](https://github.com/poseidon/terraform-render-bootstrap) Terraform module.

## System Images

Typhoon publishes Kubelet [container images](/topics/security/#container-images) to Quay.io (default) and to Dockerhub (in case of a Quay [outage](https://github.com/poseidon/typhoon/issues/735) or breach). Quay automated builds also provide the option for fully verifiable tagged images (`build-{short_sha}`).

To set an alternative etcd image or Kubelet image, use a snippet to set a systemd dropin.

=== "Kubelet"

    ```yaml
    # kubelet-image-override.yaml
    variant: fcos           <- remove for Flatcar Linux
    version: 1.4.0          <- remove for Flatcar Linux
    systemd:
      units:
        - name: kubelet.service
          dropins:
            - name: 10-image-override.conf
              contents: |
                [Service]
                Environment=KUBELET_IMAGE=docker.io/psdn/kubelet:v1.18.3
    ```

=== "etcd"

    ```yaml
    # etcd-image-override.yaml
    variant: fcos           <- remove for Flatcar Linux
    version: 1.4.0          <- remove for Flatcar Linux
    systemd:
      units:
        - name: etcd-member.service
          dropins:
            - name: 10-image-override.conf
              contents: |
                [Service]
                Environment=ETCD_IMAGE=quay.io/mymirror/etcd:v3.4.12
    ```

Then reference the snippet in the cluster or worker pool definition.

```tf
module "nemo" {
  ...

  worker_snippets = [
    file("./snippets/kubelet-image-override.yaml")
  ]
  ...
}
```

