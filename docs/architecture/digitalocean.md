# DigitalOcean

## Load Balancing

![Load Balancing](/img/typhoon-digitalocean-load-balancing.png)

### kube-apiserver

DNS A records round-robin[^1] resolve IPv4 TCP/6443 traffic to controller droplets (regardless of whether their `kube-apiserver` is healthy). Clusters with multiple controllers are supported, but round-robin means 1/3 down causes ~1/3 of apiserver requests will fail).

[^1]: DigitalOcean does offer load balancers. We've opted not to use them to keep the DigitalOcean cluster cheap for developers.

### HTTP/HTTPS Ingress

DNS records (A and AAAA) round-robin[^1] resolve the `workers_dns` name (e.g. `nemo-workers.example.com`) to a worker droplet's IPv4 and IPv6 address. This allows running an Ingress controller Daemonset across workers (resolved regardless of whether its the controller is healthy).

The DNS record name is output as `workers_dns` for use in application DNS CNAME records. See [Ingess on DigitalOcean](/addons/ingress/#digital-ocean).

### TCP/UDP Services

DNS records (A and AAAA) round-robin[^1] resolve the `workers_dns` name (e.g. `nemo-workers.example.com`) to a worker droplet's IPv4 and IPv6 address. The DNS record name is output as `workers_dns` for use in application DNS CNAME records.

With round-robin as "load balancing", TCP/UDP services can be served via the same CNAME. Don't forget to add a firewall rule for the application.

### Custom Load Balancer

Add a DigitalOcean load balancer to distribute IPv4 TCP traffic (HTTP/HTTPS Ingress or TCP service) across worker droplets (tagged with `worker_tag`) with a healthy Ingress controller. A load balancer adds cost, but adds redundancy against worker failures (closer to Typhoon clusters on other platforms).

```tf
resource "digitalocean_loadbalancer" "ingress" {
  name        = "ingress"
  region      = "fra1"
  droplet_tag = module.nemo.worker_tag

  healthcheck {
    protocol          = "http"
    port              = "10254"
    path              = "/healthz"
    healthy_threshold = 2
  }

  forwarding_rule {
    entry_protocol  = "tcp"
    entry_port      = 80
    target_protocol = "tcp"
    target_port     = 80
  }

  forwarding_rule {
    entry_protocol  = "tcp"
    entry_port      = 443
    target_protocol = "tcp"
    target_port     = 443
  }

  forwarding_rule {
    entry_protocol  = "tcp"
    entry_port      = 3333
    target_protocol = "tcp"
    target_port     = 30300
  }
}
```

Define DNS A records to `digitalocean_loadbalancer.ingress.ip` instead of CNAMEs.

## Firewalls

Add firewall rules matching worker droplets with `worker_tag`.

```tf
resource "digitalocean_firewall" "some-app" {
  name = "some-app"
  tags = [module.nemo.worker_tag]
  inbound_rule {
    protocol         = "tcp"
    port_range       = "30300"
    source_addresses = ["0.0.0.0/0"]
  }
}
```

## IPv6

DigitalOcean load balancers do not have an IPv6 address. Resolving individual droplets' IPv6 addresses and using an Ingress controller with `hostNetwork: true` is a possible way to serve IPv6 traffic, if one must.

| IPv6 Feature            | Supported |
|-------------------------|-----------|
| Node IPv6 address       | Yes       |
| Node Outbound IPv6      | Yes       |
| Kubernetes Ingress IPv6 | Possible  |

