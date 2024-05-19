resource "kubernetes_config_map" "config" {
  metadata {
    name      = "flannel-config"
    namespace = "kube-system"
    labels = {
      k8s-app = "flannel"
      tier    = "node"
    }
  }

  data = {
    "cni-conf.json" = <<-EOF
      {
        "name": "cbr0",
        "cniVersion": "0.3.1",
        "plugins": [
          {
            "type": "flannel",
            "delegate": {
              "hairpinMode": true,
              "isDefaultGateway": true
            }
          },
          {
            "type": "portmap",
            "capabilities": {
              "portMappings": true
            }
          }
        ]
      }
    EOF
    "net-conf.json" = <<-EOF
      {
        "Network": "${var.pod_cidr}",
        "Backend": {
          "Type": "vxlan",
          "Port": 4789
        }
      }
    EOF
  }
}

