resource "kubernetes_deployment" "operator" {
  wait_for_rollout = false
  metadata {
    name      = "cilium-operator"
    namespace = "kube-system"
  }
  spec {
    replicas = 1
    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_unavailable = "1"
      }
    }
    selector {
      match_labels = {
        name = "cilium-operator"
      }
    }
    template {
      metadata {
        labels = {
          name = "cilium-operator"
        }
        annotations = {
          "prometheus.io/scrape" = "true"
          "prometheus.io/port"   = "9963"
        }
      }
      spec {
        host_network         = true
        priority_class_name  = "system-cluster-critical"
        service_account_name = "cilium-operator"
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
        topology_spread_constraint {
          max_skew           = 1
          topology_key       = "kubernetes.io/hostname"
          when_unsatisfiable = "DoNotSchedule"
          label_selector {
            match_labels = {
              name = "cilium-operator"
            }
          }
        }
        automount_service_account_token = true
        enable_service_links            = false
        container {
          name    = "cilium-operator"
          image   = "quay.io/cilium/operator-generic:v1.16.1"
          command = ["cilium-operator-generic"]
          args = [
            "--config-dir=/tmp/cilium/config-map",
            "--debug=$(CILIUM_DEBUG)"
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
          env {
            name = "CILIUM_DEBUG"
            value_from {
              config_map_key_ref {
                name     = "cilium"
                key      = "debug"
                optional = true
              }
            }
          }
          port {
            name           = "metrics"
            protocol       = "TCP"
            host_port      = 9963
            container_port = 9963
          }
          port {
            name           = "health"
            container_port = 9234
            protocol       = "TCP"
          }
          liveness_probe {
            http_get {
              scheme = "HTTP"
              host   = "127.0.0.1"
              port   = "9234"
              path   = "/healthz"
            }
            initial_delay_seconds = 60
            timeout_seconds       = 3
            period_seconds        = 10
          }
          readiness_probe {
            http_get {
              scheme = "HTTP"
              host   = "127.0.0.1"
              port   = "9234"
              path   = "/healthz"
            }
            timeout_seconds   = 3
            period_seconds    = 15
            failure_threshold = 5
          }
          volume_mount {
            name       = "config"
            read_only  = true
            mount_path = "/tmp/cilium/config-map"
          }
        }

        volume {
          name = "config"
          config_map {
            name = "cilium"
          }
        }
      }
    }
  }
}

