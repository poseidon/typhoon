resource "kubernetes_cluster_role" "operator" {
  metadata {
    name = "cilium-operator"
  }

  # detect and restart [core|kube]dns pods on startup
  rule {
    verbs      = ["get", "list", "watch", "delete"]
    api_groups = [""]
    resources  = ["pods"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = [""]
    resources  = ["nodes"]
  }

  rule {
    verbs      = ["patch"]
    api_groups = [""]
    resources  = ["nodes", "nodes/status"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["discovery.k8s.io"]
    resources  = ["endpointslices"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["services"]
  }

  # Perform LB IP allocation for BGP
  rule {
    verbs      = ["update"]
    api_groups = [""]
    resources  = ["services/status"]
  }

  # Perform the translation of a CNP that contains `ToGroup` to its endpoints
  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["services", "endpoints", "namespaces"]
  }

  rule {
    verbs      = ["*"]
    api_groups = ["cilium.io"]
    resources  = ["ciliumnetworkpolicies", "ciliumnetworkpolicies/status", "ciliumnetworkpolicies/finalizers", "ciliumclusterwidenetworkpolicies", "ciliumclusterwidenetworkpolicies/status", "ciliumclusterwidenetworkpolicies/finalizers", "ciliumendpoints", "ciliumendpoints/status", "ciliumendpoints/finalizers", "ciliumnodes", "ciliumnodes/status", "ciliumnodes/finalizers", "ciliumidentities", "ciliumidentities/status", "ciliumidentities/finalizers", "ciliumlocalredirectpolicies", "ciliumlocalredirectpolicies/status", "ciliumlocalredirectpolicies/finalizers", "ciliumendpointslices", "ciliumloadbalancerippools", "ciliumloadbalancerippools/status", "ciliumcidrgroups", "ciliuml2announcementpolicies", "ciliuml2announcementpolicies/status", "ciliumpodippools"]
  }

  rule {
    verbs      = ["create", "get", "list", "update", "watch"]
    api_groups = ["apiextensions.k8s.io"]
    resources  = ["customresourcedefinitions"]
  }

  # Cilium leader elects if among multiple operator replicas
  rule {
    verbs      = ["create", "get", "update"]
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
  }
}

resource "kubernetes_cluster_role" "agent" {
  metadata {
    name = "cilium-agent"
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["networking.k8s.io"]
    resources  = ["networkpolicies"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["discovery.k8s.io"]
    resources  = ["endpointslices"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["namespaces", "services", "pods", "endpoints", "nodes"]
  }

  rule {
    verbs      = ["patch"]
    api_groups = [""]
    resources  = ["nodes/status"]
  }

  rule {
    verbs      = ["create", "get", "list", "watch", "update"]
    api_groups = ["apiextensions.k8s.io"]
    resources  = ["customresourcedefinitions"]
  }

  rule {
    verbs      = ["*"]
    api_groups = ["cilium.io"]
    resources  = ["ciliumnetworkpolicies", "ciliumnetworkpolicies/status", "ciliumclusterwidenetworkpolicies", "ciliumclusterwidenetworkpolicies/status", "ciliumendpoints", "ciliumendpoints/status", "ciliumnodes", "ciliumnodes/status", "ciliumidentities", "ciliumidentities/status", "ciliumlocalredirectpolicies", "ciliumlocalredirectpolicies/status", "ciliumegressnatpolicies", "ciliumendpointslices", "ciliumcidrgroups", "ciliuml2announcementpolicies", "ciliuml2announcementpolicies/status", "ciliumpodippools"]
  }
}

