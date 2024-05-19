resource "kubernetes_cluster_role" "flannel" {
  metadata {
    name = "flannel"
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes/status"]
    verbs      = ["patch"]
  }
}

