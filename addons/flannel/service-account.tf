resource "kubernetes_service_account" "flannel" {
  metadata {
    name      = "flannel"
    namespace = "kube-system"
  }
}

