data "ignition_config" "worker" {
  users    = ["${data.ignition_user.core.id}"]

  networkd = [
    "${data.ignition_networkd_unit.eth0.id}",
  ]

  systemd = [
    "${data.ignition_systemd_unit.docker.id}",
    "${data.ignition_systemd_unit.locksmithd.id}",
    "${data.ignition_systemd_unit.wait-for-dns.id}",
    "${data.ignition_systemd_unit.kubelet-node.id}",
    "${data.ignition_systemd_unit.delete-node.id}"
  ]

  files = [
    "${data.ignition_file.kubeconfig.id}",
    "${data.ignition_file.kubelet-env.id}",
    "${data.ignition_file.max-user-watches.id}",
    "${data.ignition_file.delete-node.id}"
  ]
}
