resource "kubernetes_cluster_role_binding" "flannel" {
  metadata {
    name = "flannel"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "flannel"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "flannel"
    namespace = "kube-system"
  }
}

