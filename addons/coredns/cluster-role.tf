resource "kubernetes_cluster_role" "coredns" {
  metadata {
    name = "system:coredns"
  }
  rule {
    api_groups = [""]
    resources = [
      "endpoints",
      "services",
      "pods",
      "namespaces",
    ]
    verbs = [
      "list",
      "watch",
    ]
  }
  rule {
    api_groups = [""]
    resources = [
      "nodes",
    ]
    verbs = [
      "get",
    ]
  }
  rule {
    api_groups = ["discovery.k8s.io"]
    resources = [
      "endpointslices",
    ]
    verbs = [
      "list",
      "watch",
    ]
  }
}
