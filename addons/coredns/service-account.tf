resource "kubernetes_service_account" "coredns" {
  metadata {
    name      = "coredns"
    namespace = "kube-system"
  }
  automount_service_account_token = false
}


resource "kubernetes_cluster_role_binding" "coredns" {
  metadata {
    name = "system:coredns"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:coredns"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "coredns"
    namespace = "kube-system"
  }
}
