data "template_file" "controller-configs" {
  count = "${length(var.controller_names)}"

  template = "${file("${path.module}/cl/controller.yaml.tmpl")}"

  vars {
    domain_name           = "${element(var.controller_names, count.index)}.${var.machine_domain}"
    etcd_name             = "${element(var.controller_names, count.index)}"
    etcd_initial_cluster  = "${join(",", formatlist("%s=https://%s.%s:2380", var.controller_names, var.controller_names, var.machine_domain))}"
    k8s_dns_service_ip    = "${module.bootkube.kube_dns_service_ip}"
    cluster_domain_suffix = "${var.cluster_domain_suffix}"
    ssh_authorized_key    = "${var.ssh_authorized_key}"
  }
}

data "ct_config" "controllers" {
  count = "${length(var.controller_names)}"

  content = "${element(data.template_file.controller-configs.*.rendered, count.index)}"
}

// Kubernetes Worker profiles
data "template_file" "worker-configs" {
  count = "${length(var.worker_names)}"

  template = "${file("${path.module}/cl/worker.yaml.tmpl")}"

  vars {
    domain_name           = "${element(var.worker_names, count.index)}.${var.machine_domain}"
    k8s_dns_service_ip    = "${module.bootkube.kube_dns_service_ip}"
    cluster_domain_suffix = "${var.cluster_domain_suffix}"
    ssh_authorized_key    = "${var.ssh_authorized_key}"
  }
}

// invoke ct to generate ignition configs
data "ct_config" "workers" {
  count = "${length(var.worker_names)}"

  content = "${element(data.template_file.worker-configs.*.rendered, count.index)}"
}
