resource "kubernetes_cluster_role_binding" "operator" {
  metadata {
    name = "cilium-operator"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cilium-operator"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "cilium-operator"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "agent" {
  metadata {
    name = "cilium-agent"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cilium-agent"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "cilium-agent"
    namespace = "kube-system"
  }
}

