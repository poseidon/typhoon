resource "kubernetes_daemonset" "cilium" {
  wait_for_rollout = false

  metadata {
    name      = "cilium"
    namespace = "kube-system"
    labels = {
      k8s-app = "cilium"
    }
  }
  spec {
    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_unavailable = "1"
      }
    }
    selector {
      match_labels = {
        k8s-app = "cilium-agent"
      }
    }
    template {
      metadata {
        labels = {
          k8s-app = "cilium-agent"
        }
        annotations = {
          "prometheus.io/port"   = "9962"
          "prometheus.io/scrape" = "true"
        }
      }
      spec {
        host_network         = true
        priority_class_name  = "system-node-critical"
        service_account_name = "cilium-agent"
        security_context {
          seccomp_profile {
            type = "RuntimeDefault"
          }
        }
        toleration {
          key      = "node-role.kubernetes.io/controller"
          operator = "Exists"
        }
        toleration {
          key      = "node.kubernetes.io/not-ready"
          operator = "Exists"
        }
        dynamic "toleration" {
          for_each = var.daemonset_tolerations
          content {
            key      = toleration.value
            operator = "Exists"
          }
        }
        automount_service_account_token = true
        enable_service_links            = false

        # Cilium v1.13.1 starts installing CNI plugins in yet another init container
        # https://github.com/cilium/cilium/pull/24075
        init_container {
          name    = "install-cni"
          image   = "quay.io/cilium/cilium:v1.16.1"
          command = ["/install-plugin.sh"]
          security_context {
            allow_privilege_escalation = true
            privileged                 = true
            capabilities {
              drop = ["ALL"]
            }
          }
          volume_mount {
            name       = "cni-bin-dir"
            mount_path = "/host/opt/cni/bin"
          }
        }

        # Required to mount cgroup2 filesystem on the underlying Kubernetes node.
        # We use nsenter command with host's cgroup and mount namespaces enabled.
        init_container {
          name  = "mount-cgroup"
          image = "quay.io/cilium/cilium:v1.16.1"
          command = [
            "sh",
            "-ec",
            # The statically linked Go program binary is invoked to avoid any
            # dependency on utilities like sh and mount that can be missing on certain
            # distros installed on the underlying host. Copy the binary to the
            # same directory where we install cilium cni plugin so that exec permissions
            # are available.
            "cp /usr/bin/cilium-mount /hostbin/cilium-mount && nsenter --cgroup=/hostproc/1/ns/cgroup --mount=/hostproc/1/ns/mnt \"$${BIN_PATH}/cilium-mount\" $CGROUP_ROOT; rm /hostbin/cilium-mount"
          ]
          env {
            name  = "CGROUP_ROOT"
            value = "/run/cilium/cgroupv2"
          }
          env {
            name  = "BIN_PATH"
            value = "/opt/cni/bin"
          }
          security_context {
            allow_privilege_escalation = true
            privileged                 = true
          }
          volume_mount {
            name       = "hostproc"
            mount_path = "/hostproc"
          }
          volume_mount {
            name       = "cni-bin-dir"
            mount_path = "/hostbin"
          }
        }

        init_container {
          name    = "clean-cilium-state"
          image   = "quay.io/cilium/cilium:v1.16.1"
          command = ["/init-container.sh"]
          security_context {
            allow_privilege_escalation = true
            privileged                 = true
          }
          volume_mount {
            name       = "sys-fs-bpf"
            mount_path = "/sys/fs/bpf"
          }
          volume_mount {
            name       = "var-run-cilium"
            mount_path = "/var/run/cilium"
          }
          # Required to mount cgroup filesystem from the host to cilium agent pod
          volume_mount {
            name              = "cilium-cgroup"
            mount_path        = "/run/cilium/cgroupv2"
            mount_propagation = "HostToContainer"
          }
        }

        container {
          name    = "cilium-agent"
          image   = "quay.io/cilium/cilium:v1.16.1"
          command = ["cilium-agent"]
          args = [
            "--config-dir=/tmp/cilium/config-map"
          ]
          env {
            name = "K8S_NODE_NAME"
            value_from {
              field_ref {
                api_version = "v1"
                field_path  = "spec.nodeName"
              }
            }
          }
          env {
            name = "CILIUM_K8S_NAMESPACE"
            value_from {
              field_ref {
                api_version = "v1"
                field_path  = "metadata.namespace"
              }
            }
          }
          env {
            name = "KUBERNETES_SERVICE_HOST"
            value_from {
              config_map_key_ref {
                name = "in-cluster"
                key  = "apiserver-host"
              }
            }
          }
          env {
            name = "KUBERNETES_SERVICE_PORT"
            value_from {
              config_map_key_ref {
                name = "in-cluster"
                key  = "apiserver-port"
              }
            }
          }
          port {
            name           = "peer-service"
            protocol       = "TCP"
            container_port = 4244
          }
          # Metrics
          port {
            name           = "metrics"
            protocol       = "TCP"
            container_port = 9962
          }
          port {
            name           = "envoy-metrics"
            protocol       = "TCP"
            container_port = 9964
          }
          port {
            name           = "hubble-metrics"
            protocol       = "TCP"
            container_port = 9965
          }
          # Not yet used, prefer exec's
          port {
            name           = "health"
            protocol       = "TCP"
            container_port = 9876
          }
          lifecycle {
            pre_stop {
              exec {
                command = ["/cni-uninstall.sh"]
              }
            }
          }
          security_context {
            allow_privilege_escalation = true
            privileged                 = true
          }
          liveness_probe {
            exec {
              command = ["cilium", "status", "--brief"]
            }
            initial_delay_seconds = 120
            timeout_seconds       = 5
            period_seconds        = 30
            success_threshold     = 1
            failure_threshold     = 10
          }
          readiness_probe {
            exec {
              command = ["cilium", "status", "--brief"]
            }
            initial_delay_seconds = 5
            timeout_seconds       = 5
            period_seconds        = 20
            success_threshold     = 1
            failure_threshold     = 3
          }
          # Load kernel modules
          volume_mount {
            name       = "lib-modules"
            read_only  = true
            mount_path = "/lib/modules"
          }
          # Access iptables concurrently
          volume_mount {
            name       = "xtables-lock"
            mount_path = "/run/xtables.lock"
          }
          # Keep state between restarts
          volume_mount {
            name       = "var-run-cilium"
            mount_path = "/var/run/cilium"
          }
          volume_mount {
            name              = "sys-fs-bpf"
            mount_path        = "/sys/fs/bpf"
            mount_propagation = "Bidirectional"
          }
          # Configuration
          volume_mount {
            name       = "config"
            read_only  = true
            mount_path = "/tmp/cilium/config-map"
          }
          # Install config on host
          volume_mount {
            name       = "cni-conf-dir"
            mount_path = "/host/etc/cni/net.d"
          }
          # Hubble
          volume_mount {
            name       = "hubble-tls"
            mount_path = "/var/lib/cilium/tls/hubble"
            read_only  = true
          }
        }
        termination_grace_period_seconds = 1

        # Load kernel modules
        volume {
          name = "lib-modules"
          host_path {
            path = "/lib/modules"
          }
        }
        # Access iptables concurrently with other processes (e.g. kube-proxy)
        volume {
          name = "xtables-lock"
          host_path {
            path = "/run/xtables.lock"
            type = "FileOrCreate"
          }
        }
        # Keep state between restarts
        volume {
          name = "var-run-cilium"
          host_path {
            path = "/var/run/cilium"
            type = "DirectoryOrCreate"
          }
        }
        # Keep state for bpf maps between restarts
        volume {
          name = "sys-fs-bpf"
          host_path {
            path = "/sys/fs/bpf"
            type = "DirectoryOrCreate"
          }
        }
        # Mount host cgroup2 filesystem
        volume {
          name = "hostproc"
          host_path {
            path = "/proc"
            type = "Directory"
          }
        }
        volume {
          name = "cilium-cgroup"
          host_path {
            path = "/run/cilium/cgroupv2"
            type = "DirectoryOrCreate"
          }
        }
        # Read configuration
        volume {
          name = "config"
          config_map {
            name = "cilium"
          }
        }
        # Install CNI plugin and config on host
        volume {
          name = "cni-bin-dir"
          host_path {
            path = "/opt/cni/bin"
            type = "DirectoryOrCreate"
          }
        }
        volume {
          name = "cni-conf-dir"
          host_path {
            path = "/etc/cni/net.d"
            type = "DirectoryOrCreate"
          }
        }
        # Hubble TLS (optional)
        volume {
          name = "hubble-tls"
          projected {
            default_mode = "0400"
            sources {
              secret {
                name     = "hubble-server-certs"
                optional = true
                items {
                  key  = "ca.crt"
                  path = "client-ca.crt"
                }
                items {
                  key  = "tls.crt"
                  path = "server.crt"
                }
                items {
                  key  = "tls.key"
                  path = "server.key"
                }
              }
            }
          }
        }
      }
    }
  }
}

