resource "kubernetes_service_account" "operator" {
  metadata {
    name      = "cilium-operator"
    namespace = "kube-system"
  }
  automount_service_account_token = false
}

resource "kubernetes_service_account" "agent" {
  metadata {
    name      = "cilium-agent"
    namespace = "kube-system"
  }
  automount_service_account_token = false
}
