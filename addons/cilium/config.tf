resource "kubernetes_config_map" "cilium" {
  metadata {
    name      = "cilium"
    namespace = "kube-system"
  }
  data = {
    # Identity allocation mode selects how identities are shared between cilium
    # nodes by setting how they are stored. The options are "crd" or "kvstore".
    # - "crd" stores identities in kubernetes as CRDs (custom resource definition).
    #   These can be queried with:
    #     kubectl get ciliumid
    # - "kvstore" stores identities in a kvstore, etcd or consul, that is
    #   configured below. Cilium versions before 1.6 supported only the kvstore
    #   backend. Upgrades from these older cilium versions should continue using
    #   the kvstore by commenting out the identity-allocation-mode below, or
    #   setting it to "kvstore".
    identity-allocation-mode    = "crd"
    cilium-endpoint-gc-interval = "5m0s"
    nodes-gc-interval           = "5m0s"

    # If you want to run cilium in debug mode change this value to true
    debug = "false"
    # The agent can be put into the following three policy enforcement modes
    # default, always and never.
    # https://docs.cilium.io/en/latest/policy/intro/#policy-enforcement-modes
    enable-policy = "default"

    # Prometheus
    enable-metrics                 = "true"
    prometheus-serve-addr          = ":9962"
    operator-prometheus-serve-addr = ":9963"
    proxy-prometheus-port          = "9964" # envoy

    # Enable IPv4 addressing. If enabled, all endpoints are allocated an IPv4
    # address.
    enable-ipv4 = "true"

    # Enable IPv6 addressing. If enabled, all endpoints are allocated an IPv6
    # address.
    enable-ipv6 = "false"

    # Enable probing for a more efficient clock source for the BPF datapath
    enable-bpf-clock-probe = "true"

    # Enable use of transparent proxying mechanisms (Linux 5.7+)
    enable-bpf-tproxy = "false"

    # If you want cilium monitor to aggregate tracing for packets, set this level
    # to "low", "medium", or "maximum". The higher the level, the less packets
    # that will be seen in monitor output.
    monitor-aggregation = "medium"

    # The monitor aggregation interval governs the typical time between monitor
    # notification events for each allowed connection.
    #
    # Only effective when monitor aggregation is set to "medium" or higher.
    monitor-aggregation-interval = "5s"

    # The monitor aggregation flags determine which TCP flags which, upon the
    # first observation, cause monitor notifications to be generated.
    #
    # Only effective when monitor aggregation is set to "medium" or higher.
    monitor-aggregation-flags = "all"

    # Specifies the ratio (0.0-1.0) of total system memory to use for dynamic
    # sizing of the TCP CT, non-TCP CT, NAT and policy BPF maps.
    bpf-map-dynamic-size-ratio = "0.0025"
    # bpf-policy-map-max specified the maximum number of entries in endpoint
    # policy map (per endpoint)
    bpf-policy-map-max = "16384"
    # bpf-lb-map-max specifies the maximum number of entries in bpf lb service,
    # backend and affinity maps.
    bpf-lb-map-max = "65536"

    # Pre-allocation of map entries allows per-packet latency to be reduced, at
    # the expense of up-front memory allocation for the entries in the maps. The
    # default value below will minimize memory usage in the default installation;
    # users who are sensitive to latency may consider setting this to "true".
    #
    # This option was introduced in Cilium 1.4. Cilium 1.3 and earlier ignore
    # this option and behave as though it is set to "true".
    #
    # If this value is modified, then during the next Cilium startup the restore
    # of existing endpoints and tracking of ongoing connections may be disrupted.
    # As a result, reply packets may be dropped and the load-balancing decisions
    # for established connections may change.
    #
    # If this option is set to "false" during an upgrade from 1.3 or earlier to
    # 1.4 or later, then it may cause one-time disruptions during the upgrade.
    preallocate-bpf-maps = "false"

    # Name of the cluster. Only relevant when building a mesh of clusters.
    cluster-name = "default"
    # Unique ID of the cluster. Must be unique across all conneted clusters and
    # in the range of 1 and 255. Only relevant when building a mesh of clusters.
    cluster-id = "0"

    # Encapsulation mode for communication between nodes
    # Possible values:
    #   - disabled
    #   - vxlan (default)
    #   - geneve
    routing-mode = "tunnel"
    tunnel       = "vxlan"
    # Enables L7 proxy for L7 policy enforcement and visibility
    enable-l7-proxy = "true"

    auto-direct-node-routes = "false"

    # enableXTSocketFallback enables the fallback compatibility solution
    # when the xt_socket kernel module is missing and it is needed for
    # the datapath L7 redirection to work properly.  See documentation
    # for details on when this can be disabled:
    # http://docs.cilium.io/en/latest/install/system_requirements/#admin-kernel-version.
    enable-xt-socket-fallback = "true"

    # installIptablesRules enables installation of iptables rules to allow for
    # TPROXY (L7 proxy injection), itpables based masquerading and compatibility
    # with kube-proxy. See documentation for details on when this can be
    # disabled.
    install-iptables-rules = "true"

    # masquerade traffic leaving the node destined for outside
    enable-ipv4-masquerade = "true"
    enable-ipv6-masquerade = "false"

    # bpfMasquerade enables masquerading with BPF instead of iptables
    enable-bpf-masquerade = "true"

    # kube-proxy
    kube-proxy-replacement                      = "true"
    kube-proxy-replacement-healthz-bind-address = ":10256"
    enable-session-affinity                     = "true"

    # ClusterIPs from host namespace
    bpf-lb-sock = "true"
    # ClusterIPs from external nodes
    bpf-lb-external-clusterip = "true"

    # NodePort
    enable-node-port             = "true"
    enable-health-check-nodeport = "false"

    # ExternalIPs
    enable-external-ips = "true"

    # HostPort
    enable-host-port = "true"

    # IPAM
    ipam                        = "cluster-pool"
    disable-cnp-status-updates  = "true"
    cluster-pool-ipv4-cidr      = "${var.pod_cidr}"
    cluster-pool-ipv4-mask-size = "24"

    # Health
    agent-health-port               = "9876"
    enable-health-checking          = "true"
    enable-endpoint-health-checking = "true"

    # Identity
    enable-well-known-identities = "false"
    enable-remote-node-identity  = "true"

    # Hubble server
    enable-hubble                  = var.enable_hubble
    hubble-disable-tls             = "false"
    hubble-listen-address          = ":4244"
    hubble-socket-path             = "/var/run/cilium/hubble.sock"
    hubble-tls-client-ca-files     = "/var/lib/cilium/tls/hubble/client-ca.crt"
    hubble-tls-cert-file           = "/var/lib/cilium/tls/hubble/server.crt"
    hubble-tls-key-file            = "/var/lib/cilium/tls/hubble/server.key"
    hubble-export-file-max-backups = "5"
    hubble-export-file-max-size-mb = "10"

    # Hubble metrics
    hubble-metrics-server      = ":9965"
    hubble-metrics             = "dns drop tcp flow port-distribution icmp httpV2"
    enable-hubble-open-metrics = "false"


    # Misc
    enable-bandwidth-manager        = "false"
    enable-local-redirect-policy    = "false"
    policy-audit-mode               = "false"
    operator-api-serve-addr         = "127.0.0.1:9234"
    enable-l2-neigh-discovery       = "true"
    enable-k8s-terminating-endpoint = "true"
    enable-k8s-networkpolicy        = "true"
    external-envoy-proxy            = "false"
    write-cni-conf-when-ready       = "/host/etc/cni/net.d/05-cilium.conflist"
    cni-exclusive                   = "true"
    cni-log-file                    = "/var/run/cilium/cilium-cni.log"
  }
}

