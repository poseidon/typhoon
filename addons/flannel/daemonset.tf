resource "kubernetes_daemonset" "flannel" {
  metadata {
    name      = "flannel"
    namespace = "kube-system"
    labels = {
      k8s-app = "flannel"
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
        k8s-app = "flannel"
      }
    }
    template {
      metadata {
        labels = {
          k8s-app = "flannel"
        }
      }
      spec {
        host_network         = true
        priority_class_name  = "system-node-critical"
        service_account_name = "flannel"
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
        init_container {
          name    = "install-cni"
          image   = "quay.io/poseidon/flannel-cni:v0.4.2"
          command = ["/install-cni.sh"]
          env {
            name = "CNI_NETWORK_CONFIG"
            value_from {
              config_map_key_ref {
                name = "flannel-config"
                key  = "cni-conf.json"
              }
            }
          }
          volume_mount {
            name       = "cni-bin-dir"
            mount_path = "/host/opt/cni/bin/"
          }
          volume_mount {
            name       = "cni-conf-dir"
            mount_path = "/host/etc/cni/net.d"
          }
        }

        container {
          name  = "flannel"
          image = "docker.io/flannel/flannel:v0.25.5"
          command = [
            "/opt/bin/flanneld",
            "--ip-masq",
            "--kube-subnet-mgr",
            "--iface=$(POD_IP)"
          ]
          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }
          env {
            name = "POD_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }
          env {
            name = "POD_IP"
            value_from {
              field_ref {
                field_path = "status.podIP"
              }
            }
          }
          security_context {
            privileged = true
          }
          resources {
            requests = {
              cpu = "100m"
            }
          }
          volume_mount {
            name       = "flannel-config"
            mount_path = "/etc/kube-flannel/"
          }
          volume_mount {
            name       = "run-flannel"
            mount_path = "/run/flannel"
          }
          volume_mount {
            name       = "xtables-lock"
            mount_path = "/run/xtables.lock"
          }
        }

        volume {
          name = "flannel-config"
          config_map {
            name = "flannel-config"
          }
        }
        volume {
          name = "run-flannel"
          host_path {
            path = "/run/flannel"
          }
        }
        # Used by install-cni
        volume {
          name = "cni-bin-dir"
          host_path {
            path = "/opt/cni/bin"
          }
        }
        volume {
          name = "cni-conf-dir"
          host_path {
            path = "/etc/cni/net.d"
            type = "DirectoryOrCreate"
          }
        }
        # Acces iptables concurrently
        volume {
          name = "xtables-lock"
          host_path {
            path = "/run/xtables.lock"
            type = "FileOrCreate"
          }
        }
      }
    }
  }
}

