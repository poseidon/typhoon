# Container Linux Update Operator

The [Container Linux Update Operator](https://github.com/coreos/container-linux-update-operator) (i.e. CLUO) coordinates reboots of auto-updating Container Linux nodes so that one node reboots at a time and nodes are drained before reboot. CLUO enables the auto-update behavior Container Linux clusters are known for, but does so in a Kubernetes native way.

## Create

Create the `update-operator` deployment and `update-agent` DaemonSet.

```sh
kubectl apply -f addons/cluo -R
```

## Usage

`update-agent` runs as a DaemonSet and annotates a node when `update-engine.service` indicates an update has been installed and a reboot is needed. It also adds additional labels and annotations to nodes.

```
$ kubectl get nodes --show-labels
...
container-linux-update.v1.coreos.com/group=stable
container-linux-update.v1.coreos.com/version=1632.3.0
```

`update-operator` ensures one node reboots at a time and that pods are drained prior to reboot.

!!! note ""
    CLUO replaces `locksmithd` reboot coordination. The `update_engine` systemd unit on hosts still performs the Container Linux update check, download, and install to the inactive partition.


