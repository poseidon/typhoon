resource "kubernetes_service" "coredns" {
  metadata {
    name      = "coredns"
    namespace = "kube-system"
    labels = {
      "k8s-app"            = "coredns"
      "kubernetes.io/name" = "CoreDNS"
    }
    annotations = {
      "prometheus.io/scrape" = "true"
      "prometheus.io/port"   = "9153"
    }
  }
  spec {
    type       = "ClusterIP"
    cluster_ip = var.cluster_dns_service_ip
    selector = {
      k8s-app = "coredns"
    }
    port {
      name     = "dns"
      protocol = "UDP"
      port     = 53
    }
    port {
      name     = "dns-tcp"
      protocol = "TCP"
      port     = 53
    }
  }
}
