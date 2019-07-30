# Google Cloud

## Load Balancing

![Load Balancing](/img/typhoon-gcp-load-balancing.png)

### kube-apiserver

A global forwarding rule (IPv4 anycast) and TCP Proxy distribute IPv4 TCP/443 traffic across a backend service with zonal instance groups of controller(s) with a healthy `kube-apiserver` (TCP/6443). Clusters with multiple controllers span zones in a region to tolerate zone outages.

Notes:

* GCP TCP Proxy limits external port options (e.g. must use 443, not 6443)
* A regional NLB cannot be used for multi-controller (see [#190](https://github.com/poseidon/typhoon/pull/190))

### HTTP/HTTP Ingress

Global forwarding rules and a TCP Proxy distribute IPv4/IPv6 TCP/80 and TCP/443 traffic across a managed instance group of workers with a healthy Ingress Controller. Workers span zones in a region to tolerate zone outages.

The IPv4 and IPv6 anycast addresses are output as `ingress_static_ipv4` and `ingress_static_ipv6` for use in DNS A and AAAA records. See [Ingress on Google Cloud](/addons/ingress/#google-cloud).

### TCP/UDP Services

Load balance TCP/UDP applications by adding a forwarding rule to the worker target pool (output).

```tf
# Static IPv4 address for some-app Load Balancing
resource "google_compute_address" "some-app-ipv4" {
  name = "some-app-ipv4"
}

# Forward IPv4 TCP traffic to the target pool
resource "google_compute_forwarding_rule" "some-app-tcp" {
  name        = "some-app-tcp"
  ip_address  = google_compute_address.some-app-ipv4.address
  ip_protocol = "TCP"
  port_range  = "3333"
  target      = module.yavin.worker_target_pool
}


# Forward IPv4 UDP traffic to the target pool
resource "google_compute_forwarding_rule" "some-app-udp" {
  name        = "some-app-udp"
  ip_address  = google_compute_address.some-app-ipv4.address
  ip_protocol = "UDP"
  port_range  = "3333"
  target      = module.yavin.worker_target_pool
}
```

Notes:

* GCP Global Load Balancers aren't appropriate for custom TCP/UDP.
    * Backend Services require a named port corresponding to an instance group (output by Typhoon) port. Typhoon shouldn't accept a list of every TCP/UDP service that may later be hosted on the cluster.
    * Backend Services don't support UDP (i.e. rules out global load balancers)
* IPv4 Only: Regional Load Balancers use a regional IPv4 address (e.g. `google_compute_address`), no IPv6.
* Forward rules don't support differing external and internal ports. Some Ingress controllers (e.g. nginx) can proxy TCP/UDP traffic to achieve this.
* Worker target pool health checks workers `HTTP:10254/healthz` (i.e. `nginx-ingress`)

## Firewalls

Add firewall rules to the cluster's network.

```tf
resource "google_compute_firewall" "some-app" {
  name    = "some-app"
  network = module.yavin.network_self_link

  allow {
    protocol = "tcp"
    ports    = [3333]
  }
  
  allow {
    protocol = "udp"
    ports    = [3333]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["yavin-worker"]
}
```

## IPv6

Applications exposed via HTTP/HTTPS Ingress can be served over IPv6.

| IPv6 Feature            | Supported |
|-------------------------|-----------|
| Node IPv6 address       | No        |
| Node Outbound IPv6      | No        |
| Kubernetes Ingress IPv6 | Yes       |

