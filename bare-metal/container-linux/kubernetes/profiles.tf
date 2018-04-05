// Container Linux Install profile (from release.core-os.net)
resource "matchbox_profile" "container-linux-install" {
  count = "${length(var.controller_names) + length(var.worker_names)}"
  name  = "${format("%s-container-linux-install-%s", var.cluster_name, element(concat(var.controller_names, var.worker_names), count.index))}"

  kernel = "http://${var.container_linux_channel}.release.core-os.net/amd64-usr/${var.container_linux_version}/coreos_production_pxe.vmlinuz"

  initrd = [
    "http://${var.container_linux_channel}.release.core-os.net/amd64-usr/${var.container_linux_version}/coreos_production_pxe_image.cpio.gz",
  ]

  args = [
    "initrd=coreos_production_pxe_image.cpio.gz",
    "coreos.config.url=${var.matchbox_http_endpoint}/ignition?uuid=$${uuid}&mac=$${mac:hexhyp}",
    "coreos.first_boot=yes",
    "console=tty0",
    "console=ttyS0",
    "${var.kernel_args}",
  ]

  container_linux_config = "${element(data.template_file.container-linux-install-configs.*.rendered, count.index)}"
}

data "template_file" "container-linux-install-configs" {
  count = "${length(var.controller_names) + length(var.worker_names)}"

  template = "${file("${path.module}/cl/container-linux-install.yaml.tmpl")}"

  vars {
    container_linux_channel = "${var.container_linux_channel}"
    container_linux_version = "${var.container_linux_version}"
    ignition_endpoint       = "${format("%s/ignition", var.matchbox_http_endpoint)}"
    install_disk            = "${var.install_disk}"
    container_linux_oem     = "${var.container_linux_oem}"
    ssh_authorized_key      = "${var.ssh_authorized_key}"

    # only cached-container-linux profile adds -b baseurl
    baseurl_flag = ""
  }
}

// Container Linux Install profile (from matchbox /assets cache)
// Note: Admin must have downloaded container_linux_version into matchbox assets.
resource "matchbox_profile" "cached-container-linux-install" {
  count = "${length(var.controller_names) + length(var.worker_names)}"
  name  = "${format("%s-cached-container-linux-install-%s", var.cluster_name, element(concat(var.controller_names, var.worker_names), count.index))}"

  kernel = "/assets/coreos/${var.container_linux_version}/coreos_production_pxe.vmlinuz"

  initrd = [
    "/assets/coreos/${var.container_linux_version}/coreos_production_pxe_image.cpio.gz",
  ]

  args = [
    "initrd=coreos_production_pxe_image.cpio.gz",
    "coreos.config.url=${var.matchbox_http_endpoint}/ignition?uuid=$${uuid}&mac=$${mac:hexhyp}",
    "coreos.first_boot=yes",
    "console=tty0",
    "console=ttyS0",
    "${var.kernel_args}",
  ]

  container_linux_config = "${element(data.template_file.cached-container-linux-install-configs.*.rendered, count.index)}"
}

data "template_file" "cached-container-linux-install-configs" {
  count = "${length(var.controller_names) + length(var.worker_names)}"

  template = "${file("${path.module}/cl/container-linux-install.yaml.tmpl")}"

  vars {
    container_linux_channel = "${var.container_linux_channel}"
    container_linux_version = "${var.container_linux_version}"
    ignition_endpoint       = "${format("%s/ignition", var.matchbox_http_endpoint)}"
    install_disk            = "${var.install_disk}"
    container_linux_oem     = "${var.container_linux_oem}"
    ssh_authorized_key      = "${var.ssh_authorized_key}"

    # profile uses -b baseurl to install from matchbox cache
    baseurl_flag = "-b ${var.matchbox_http_endpoint}/assets/coreos"
  }
}

// Kubernetes Controller profiles
resource "matchbox_profile" "controllers" {
  count                  = "${length(var.controller_names)}"
  name                   = "${format("%s-controller-%s", var.cluster_name, element(var.controller_names, count.index))}"
  container_linux_config = "${element(data.template_file.controller-configs.*.rendered, count.index)}"
}

data "template_file" "controller-configs" {
  count = "${length(var.controller_names)}"

  template = "${file("${path.module}/cl/controller.yaml.tmpl")}"

  vars {
    domain_name           = "${element(var.controller_domains, count.index)}"
    etcd_name             = "${element(var.controller_names, count.index)}"
    etcd_initial_cluster  = "${join(",", formatlist("%s=https://%s:2380", var.controller_names, var.controller_domains))}"
    k8s_dns_service_ip    = "${module.bootkube.kube_dns_service_ip}"
    cluster_domain_suffix = "${var.cluster_domain_suffix}"
    ssh_authorized_key    = "${var.ssh_authorized_key}"

    # Terraform evaluates both sides regardless and element cannot be used on 0 length lists
    networkd_content = "${length(var.controller_networkds) == 0 ? "" : element(concat(var.controller_networkds, list("")), count.index)}"
  }
}

// Kubernetes Worker profiles
resource "matchbox_profile" "workers" {
  count                  = "${length(var.worker_names)}"
  name                   = "${format("%s-worker-%s", var.cluster_name, element(var.worker_names, count.index))}"
  container_linux_config = "${element(data.template_file.worker-configs.*.rendered, count.index)}"
}

data "template_file" "worker-configs" {
  count = "${length(var.worker_names)}"

  template = "${file("${path.module}/cl/worker.yaml.tmpl")}"

  vars {
    domain_name           = "${element(var.worker_domains, count.index)}"
    k8s_dns_service_ip    = "${module.bootkube.kube_dns_service_ip}"
    cluster_domain_suffix = "${var.cluster_domain_suffix}"
    ssh_authorized_key    = "${var.ssh_authorized_key}"

    # Terraform evaluates both sides regardless and element cannot be used on 0 length lists
    networkd_content = "${length(var.worker_networkds) == 0 ? "" : element(concat(var.worker_networkds, list("")), count.index)}"
  }
}
