resource "kubernetes_config_map" "coredns" {
  metadata {
    name      = "coredns"
    namespace = "kube-system"
  }
  data = {
    "Corefile" = <<-EOF
      .:53 {
          errors
          health {
            lameduck 5s
          }
          ready
          log . {
              class error
          }
          kubernetes ${var.cluster_domain_suffix} in-addr.arpa ip6.arpa {
              pods insecure
              fallthrough in-addr.arpa ip6.arpa
          }
          prometheus :9153
          forward . /etc/resolv.conf
          cache 30
          loop
          reload
          loadbalance
      }
  EOF
  }
}
