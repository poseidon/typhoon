## fleetlock

[fleetlock](https://github.com/poseidon/fleetlock) is a reboot coordinator for Fedora CoreOS nodes. It implements the [FleetLock](https://github.com/coreos/airlock/pull/1/files) protocol for use as a [Zincati](https://github.com/coreos/zincati) lock [strategy](https://github.com/coreos/zincati/blob/master/docs/usage/updates-strategy.md) backend.

Declare a Zincati `fleet_lock` strategy when provisioning Fedora CoreOS nodes via [snippets](/advanced/customization/#hosts).

```yaml
variant: fcos
version: 1.5.0
storage:
  files:
    - path: /etc/zincati/config.d/55-update-strategy.toml
      contents:
        inline: |
          [updates]
          strategy = "fleet_lock"
          [updates.fleet_lock]
          base_url = "http://10.3.0.15/"
```

```tf
module "nemo" {
  ...
  controller_snippets = [
    file("./snippets/zincati-strategy.yaml"),
  ]
  worker_snippets = [
    file("./snippets/zincati-strategy.yaml"),
  ]
}
```

Apply fleetlock based on the example manifests.

```sh
git clone git@github.com:poseidon/fleetlock.git
kubectl apply -f examples/k8s
```

