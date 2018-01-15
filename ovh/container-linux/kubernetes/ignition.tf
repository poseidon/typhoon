locals {
  k8s_dns_service_ip      = "${cidrhost(var.service_cidr, 10)}"
  k8s_etcd_service_ip     = "${cidrhost(var.service_cidr, 15)}"
  ssh_authorized_key      = "${var.ssh_authorized_key}"
  kubeconfig_ca_cert      = "${module.bootkube.ca_cert}"
  kubeconfig_kubelet_cert = "${module.bootkube.kubelet_cert}"
  kubeconfig_kubelet_key  = "${module.bootkube.kubelet_key}"
  kubeconfig_server       = "${module.bootkube.server}"
  network_route_tpl = "[Route]\nDestination=%s\nGatewayOnLink=yes\nRouteMetric=3\nScope=link\nProtocol=kernel"
}

data "ignition_systemd_unit" "docker" {
  name    = "docker.service"
  enabled = true
}

data "ignition_networkd_unit" "eth0" {
  name = "10-eth0.network"

  content = <<IGNITION
[Match]
Name=eth0
[Network]
DHCP=ipv4
${join("\n", formatlist(local.network_route_tpl, list(var.host_cidr)))}
[DHCP]
RouteMetric=2048
IGNITION
}

data "ignition_systemd_unit" "locksmithd" {
  name    = "locksmithd.service"
  enabled = true
}

data "ignition_systemd_unit" "wait-for-dns" {
  name    = "wait-for-dns.service"
  enabled = true
  content = <<CONTENT
[Unit]
Description=Wait for DNS entries
Wants=systemd-resolved.service
Before=kubelet.service
[Service]
Type=oneshot
RemainAfterExit=true
ExecStart=/bin/sh -c 'while ! /usr/bin/grep '^[^#[:space:]]' /etc/resolv.conf > /dev/null; do sleep 1; done'
[Install]
RequiredBy=kubelet.service
RequiredBy=etcd-member.service
CONTENT
}

data "ignition_systemd_unit" "kubelet-master" {
  name    = "kubelet.service"
  enabled = true
  content = <<CONTENT
[Unit]
Description=Kubelet via Hyperkube
Wants=rpc-statd.service
[Service]
EnvironmentFile=/etc/kubernetes/kubelet.env
Environment="RKT_RUN_ARGS=--uuid-file-save=/var/cache/kubelet-pod.uuid \
  --volume=resolv,kind=host,source=/etc/resolv.conf \
  --mount volume=resolv,target=/etc/resolv.conf \
  --volume var-lib-cni,kind=host,source=/var/lib/cni \
  --mount volume=var-lib-cni,target=/var/lib/cni \
  --volume opt-cni-bin,kind=host,source=/opt/cni/bin \
  --mount volume=opt-cni-bin,target=/opt/cni/bin \
  --volume var-log,kind=host,source=/var/log \
  --mount volume=var-log,target=/var/log \
  --insecure-options=image"
ExecStartPre=/bin/mkdir -p /opt/cni/bin
ExecStartPre=/bin/mkdir -p /etc/kubernetes/manifests
ExecStartPre=/bin/mkdir -p /etc/kubernetes/cni/net.d
ExecStartPre=/bin/mkdir -p /etc/kubernetes/checkpoint-secrets
ExecStartPre=/bin/mkdir -p /etc/kubernetes/inactive-manifests
ExecStartPre=/bin/mkdir -p /var/lib/cni
ExecStartPre=/usr/bin/bash -c "grep 'certificate-authority-data' /etc/kubernetes/kubeconfig | awk '{print $2}' | base64 -d > /etc/kubernetes/ca.crt"
ExecStartPre=-/usr/bin/rkt rm --uuid-file=/var/cache/kubelet-pod.uuid
ExecStart=/usr/lib/coreos/kubelet-wrapper \
  --allow-privileged \
  --anonymous-auth=false \
  --client-ca-file=/etc/kubernetes/ca.crt \
  --cluster_dns=${local.k8s_dns_service_ip} \
  --cluster_domain=${var.cluster_domain_suffix} \
  --cni-conf-dir=/etc/kubernetes/cni/net.d \
  --exit-on-lock-contention \
  --kubeconfig=/etc/kubernetes/kubeconfig \
  --lock-file=/var/run/lock/kubelet.lock \
  --network-plugin=cni \
  --node-labels=node-role.kubernetes.io/master \
  --pod-manifest-path=/etc/kubernetes/manifests \
  --register-with-taints=node-role.kubernetes.io/master=:NoSchedule
ExecStop=-/usr/bin/rkt stop --uuid-file=/var/cache/kubelet-pod.uuid
Restart=always
RestartSec=10
[Install]
WantedBy=multi-user.target
CONTENT
}

data "ignition_systemd_unit" "kubelet-node" {
  name    = "kubelet.service"
  enabled = true
  content = <<CONTENT
[Unit]
Description=Kubelet via Hyperkube
Wants=rpc-statd.service
[Service]
EnvironmentFile=/etc/kubernetes/kubelet.env
Environment="RKT_RUN_ARGS=--uuid-file-save=/var/cache/kubelet-pod.uuid \
  --volume=resolv,kind=host,source=/etc/resolv.conf \
  --mount volume=resolv,target=/etc/resolv.conf \
  --volume var-lib-cni,kind=host,source=/var/lib/cni \
  --mount volume=var-lib-cni,target=/var/lib/cni \
  --volume opt-cni-bin,kind=host,source=/opt/cni/bin \
  --mount volume=opt-cni-bin,target=/opt/cni/bin \
  --volume var-log,kind=host,source=/var/log \
  --mount volume=var-log,target=/var/log \
  --insecure-options=image"
ExecStartPre=/bin/mkdir -p /opt/cni/bin
ExecStartPre=/bin/mkdir -p /etc/kubernetes/manifests
ExecStartPre=/bin/mkdir -p /etc/kubernetes/cni/net.d
ExecStartPre=/bin/mkdir -p /etc/kubernetes/checkpoint-secrets
ExecStartPre=/bin/mkdir -p /etc/kubernetes/inactive-manifests
ExecStartPre=/bin/mkdir -p /var/lib/cni
ExecStartPre=/usr/bin/bash -c "grep 'certificate-authority-data' /etc/kubernetes/kubeconfig | awk '{print $2}' | base64 -d > /etc/kubernetes/ca.crt"
ExecStartPre=-/usr/bin/rkt rm --uuid-file=/var/cache/kubelet-pod.uuid
ExecStart=/usr/lib/coreos/kubelet-wrapper \
  --allow-privileged \
  --anonymous-auth=false \
  --client-ca-file=/etc/kubernetes/ca.crt \
  --cluster_dns=${local.k8s_dns_service_ip} \
  --cluster_domain=${var.cluster_domain_suffix} \
  --cni-conf-dir=/etc/kubernetes/cni/net.d \
  --exit-on-lock-contention \
  --kubeconfig=/etc/kubernetes/kubeconfig \
  --lock-file=/var/run/lock/kubelet.lock \
  --network-plugin=cni \
  --node-labels=node-role.kubernetes.io/node \
  --pod-manifest-path=/etc/kubernetes/manifests
ExecStop=-/usr/bin/rkt stop --uuid-file=/var/cache/kubelet-pod.uuid
Restart=always
RestartSec=5
[Install]
WantedBy=multi-user.target
CONTENT
}

data "ignition_systemd_unit" "delete-node" {
  name    = "delete-node.service"
  enabled = true
  content = <<CONTENT
[Unit]
Description=Waiting to delete Kubernetes node on shutdown
[Service]
Type=oneshot
RemainAfterExit=true
ExecStart=/bin/true
ExecStop=/etc/kubernetes/delete-node
[Install]
WantedBy=multi-user.target
CONTENT
}

data "ignition_file" "kubeconfig" {
  filesystem = "root"
  mode = "0644"
  path = "/etc/kubernetes/kubeconfig"
  content {
    content = <<CONTENT
apiVersion: v1
kind: Config
clusters:
- name: local
  cluster:
    server: ${local.kubeconfig_server}
    certificate-authority-data: ${local.kubeconfig_ca_cert}
users:
- name: kubelet
  user:
    client-certificate-data: ${local.kubeconfig_kubelet_cert}
    client-key-data: ${local.kubeconfig_kubelet_key}
contexts:
- context:
    cluster: local
    user: kubelet
CONTENT
  }
}

data "ignition_file" "kubelet-env" {
  filesystem = "root"
  mode = "0644"
  path = "/etc/kubernetes/kubelet.env"
  content {
    content = <<CONTENT
KUBELET_IMAGE_URL=docker://gcr.io/google_containers/hyperkube
KUBELET_IMAGE_TAG=v1.9.1
CONTENT
  }
}

data "ignition_file" "delete-node" {
  filesystem = "root"
  mode = "0744"
  path = "/etc/kubernetes/delete-node"
  content {
    content = <<CONTENT
#!/bin/bash
set -e
exec /usr/bin/rkt run \
  --trust-keys-from-https \
  --volume config,kind=host,source=/etc/kubernetes \
  --mount volume=config,target=/etc/kubernetes \
  --insecure-options=image \
  docker://gcr.io/google_containers/hyperkube:v1.9.1 \
  --net=host \
  --dns=host \
  --exec=/kubectl -- --kubeconfig=/etc/kubernetes/kubeconfig delete node $(hostname)
CONTENT
  }
}

data "ignition_file" "max-user-watches" {
  filesystem = "root"
  path = "/etc/sysctl.d/max-user-watches.conf"
  content {
    content = <<CONTENT
fs.inotify.max_user_watches=16184
CONTENT
  }
}

data "template_file" "etcd_names" {
  count   = "${var.controller_count}"
  template = "etcd${count.index}"
}

data "template_file" "etcd_private_ips" {
  count   = "${var.controller_count}"
  template = "${element(flatten(openstack_networking_port_v2.port_controllers.*.all_fixed_ips), count.index)}"
}

data "ignition_systemd_unit" "etcd-member" {
  count   = "${var.controller_count}"
  name    = "etcd-member.service"
  enabled = true
  dropin {
    name = "40-etcd-cluster.conf"
    content = <<CONTENT
[Service]
Environment="ETCD_IMAGE_TAG=v3.2.13"
Environment="ETCD_NAME=etcd${count.index}"
Environment="ETCD_ADVERTISE_CLIENT_URLS=https://${element(data.template_file.etcd_dns_names.*.rendered, count.index)}:2379"
Environment="ETCD_INITIAL_ADVERTISE_PEER_URLS=https://${element(data.template_file.etcd_dns_names.*.rendered, count.index)}:2380"
Environment="ETCD_INITIAL_CLUSTER_TOKEN=etcd_${var.cluster_name}"
Environment="ETCD_LISTEN_CLIENT_URLS=https://0.0.0.0:2379"
Environment="ETCD_LISTEN_PEER_URLS=https://0.0.0.0:2380"
Environment="ETCD_INITIAL_CLUSTER=${join(",", formatlist("%s=https://%s:2380", data.template_file.etcd_names.*.rendered, data.template_file.etcd_dns_names.*.rendered))}"
Environment="ETCD_STRICT_RECONFIG_CHECK=true"
Environment="ETCD_SSL_DIR=/etc/ssl/etcd"
Environment="ETCD_TRUSTED_CA_FILE=/etc/ssl/certs/etcd/server-ca.crt"
Environment="ETCD_CERT_FILE=/etc/ssl/certs/etcd/server.crt"
Environment="ETCD_KEY_FILE=/etc/ssl/certs/etcd/server.key"
Environment="ETCD_CLIENT_CERT_AUTH=true"
Environment="ETCD_PEER_TRUSTED_CA_FILE=/etc/ssl/certs/etcd/peer-ca.crt"
Environment="ETCD_PEER_CERT_FILE=/etc/ssl/certs/etcd/peer.crt"
Environment="ETCD_PEER_KEY_FILE=/etc/ssl/certs/etcd/peer.key"
Environment="ETCD_PEER_CLIENT_CERT_AUTH=true"
CONTENT
  }
}

data "ignition_systemd_unit" "bootkube" {
  name    = "bootkube.service"
  enabled = true
  content = <<CONTENT
[Unit]
Description=Bootstrap a Kubernetes cluster
ConditionPathExists=!/opt/bootkube/init_bootkube.done
[Service]
Type=oneshot
RemainAfterExit=true
WorkingDirectory=/opt/bootkube
ExecStart=/opt/bootkube/bootkube-start
ExecStartPost=/bin/touch /opt/bootkube/init_bootkube.done
[Install]
WantedBy=multi-user.target
CONTENT
}

data "ignition_file" "bootkube-start" {
  filesystem = "root"
  path = "/opt/bootkube/bootkube-start"
  mode = "0544"
  uid = "500"
  gid = "500"
  content {
    content = <<CONTENT
#!/bin/bash
# Wrapper for bootkube start
set -e
# Move experimental manifests
[ -n "$(ls /opt/bootkube/assets/manifests-*/* 2>/dev/null)" ] && mv /opt/bootkube/assets/manifests-*/* /opt/bootkube/assets/manifests && rm -rf /opt/bootkube/assets/manifests-*
BOOTKUBE_ACI="$${BOOTKUBE_ACI:-quay.io/coreos/bootkube}"
BOOTKUBE_VERSION="$${BOOTKUBE_VERSION:-v0.9.1}"
BOOTKUBE_ASSETS="$${BOOTKUBE_ASSETS:-/opt/bootkube/assets}"
exec /usr/bin/rkt run \
  --trust-keys-from-https \
  --volume assets,kind=host,source=$${BOOTKUBE_ASSETS} \
  --mount volume=assets,target=/assets \
  --volume bootstrap,kind=host,source=/etc/kubernetes \
  --mount volume=bootstrap,target=/etc/kubernetes \
  $${RKT_OPTS} \
  $${BOOTKUBE_ACI}:$${BOOTKUBE_VERSION} \
  --net=host \
  --dns=host \
  --exec=/bootkube -- start --asset-dir=/assets "$@"
CONTENT
  }
}

data "ignition_user" "core" {
  name                = "core"
#TODO REMOVE passwd == core
  password_hash = "$1$NcEb/gcX$1LaZh7zvkTKxFYSAMOd9A/"
  ssh_authorized_keys = ["${local.ssh_authorized_key}"]
}
