resource "kubernetes_deployment" "coredns" {
  wait_for_rollout = false
  metadata {
    name      = "coredns"
    namespace = "kube-system"
    labels = {
      k8s-app              = "coredns"
      "kubernetes.io/name" = "CoreDNS"
    }
  }
  spec {
    replicas = var.replicas
    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_unavailable = "1"
      }
    }
    selector {
      match_labels = {
        k8s-app = "coredns"
        tier    = "control-plane"
      }
    }
    template {
      metadata {
        labels = {
          k8s-app = "coredns"
          tier    = "control-plane"
        }
      }
      spec {
        affinity {
          node_affinity {
            preferred_during_scheduling_ignored_during_execution {
              weight = 100
              preference {
                match_expressions {
                  key      = "node.kubernetes.io/controller"
                  operator = "Exists"
                }
              }
            }
          }
          pod_anti_affinity {
            preferred_during_scheduling_ignored_during_execution {
              weight = 100
              pod_affinity_term {
                label_selector {
                  match_expressions {
                    key      = "tier"
                    operator = "In"
                    values   = ["control-plane"]
                  }
                  match_expressions {
                    key      = "k8s-app"
                    operator = "In"
                    values   = ["coredns"]
                  }
                }
                topology_key = "kubernetes.io/hostname"
              }
            }
          }
        }
        dns_policy          = "Default"
        priority_class_name = "system-cluster-critical"
        security_context {
          seccomp_profile {
            type = "RuntimeDefault"
          }
        }
        service_account_name = "coredns"
        toleration {
          key    = "node-role.kubernetes.io/controller"
          effect = "NoSchedule"
        }
        container {
          name  = "coredns"
          image = "registry.k8s.io/coredns/coredns:v1.11.3"
          args  = ["-conf", "/etc/coredns/Corefile"]
          port {
            name           = "dns"
            container_port = 53
            protocol       = "UDP"
          }
          port {
            name           = "dns-tcp"
            container_port = 53
            protocol       = "TCP"
          }
          port {
            name           = "metrics"
            container_port = 9153
            protocol       = "TCP"
          }
          resources {
            requests = {
              cpu    = "100m"
              memory = "70Mi"
            }
            limits = {
              memory = "170Mi"
            }
          }
          security_context {
            capabilities {
              add  = ["NET_BIND_SERVICE"]
              drop = ["all"]
            }
            read_only_root_filesystem = true
          }
          liveness_probe {
            http_get {
              path   = "/health"
              port   = "8080"
              scheme = "HTTP"
            }
            initial_delay_seconds = 60
            timeout_seconds       = 5
            success_threshold     = 1
            failure_threshold     = 5
          }
          readiness_probe {
            http_get {
              path   = "/ready"
              port   = "8181"
              scheme = "HTTP"
            }
          }
          volume_mount {
            name       = "config"
            mount_path = "/etc/coredns"
            read_only  = true
          }
        }
        volume {
          name = "config"
          config_map {
            name = "coredns"
            items {
              key  = "Corefile"
              path = "Corefile"
            }
          }
        }
      }
    }
  }
}

