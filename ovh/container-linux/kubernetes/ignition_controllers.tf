data "ignition_config" "controller" {
  count    = "${var.controller_count}"
  users    = ["${data.ignition_user.core.id}"]

  networkd = [
    "${data.ignition_networkd_unit.eth0.id}",
  ]

  systemd = [
    "${data.ignition_systemd_unit.etcd-member.*.id[count.index]}",
    "${data.ignition_systemd_unit.docker.id}",
    "${data.ignition_systemd_unit.locksmithd.id}",
    "${data.ignition_systemd_unit.wait-for-dns.id}",
    "${data.ignition_systemd_unit.kubelet-master.id}",
    "${data.ignition_systemd_unit.bootkube.id}"
  ]

  files = [
    "${data.ignition_file.kubeconfig.id}",
    "${data.ignition_file.kubelet-env.id}",
    "${data.ignition_file.max-user-watches.id}",
    "${data.ignition_file.bootkube-start.id}"
  ]
}
