# Nginx Ingress Controller

Nginx Ingress controller pods accept and demultiplex HTTP, HTTPS, TCP, or UDP traffic to backend services. Ingress controllers watch the Kubernetes API for Ingress resources and update their configuration accordingly. Ingress resources for HTTP(S) applications support virtual hosts (FQDNs), path rules, TLS termination, and SNI.

## AWS

On AWS, an elastic load balancer distributes traffic across worker nodes (i.e. an auto-scaling group) running an Ingress controller deployment on host ports 80 and 443. Firewall rules allow traffic to ports 80 and 443. Health check rules ensure only workers with a health Ingress controller receive traffic.

Create the Ingress controller deployment, service, RBAC roles, RBAC bindings, default backend, and namespace.

```
kubectl apply -R -f addons/nginx-ingress/aws
```

For each application, add a DNS CNAME resolving to the ELB's DNS record.

```
app1.example.com -> tempest-ingress.123456.us-west2.elb.amazonaws.com
aap2.example.com -> tempest-ingress.123456.us-west2.elb.amazonaws.com
app3.example.com -> tempest-ingress.123456.us-west2.elb.amazonaws.com
```

Find the ELB's DNS name through the console or use the Typhoon module's output `ingress_dns_name`. For example, you might use Terraform to manage a Google Cloud DNS record:

```tf
resource "google_dns_record_set" "some-application" {
  # DNS zone name
  managed_zone = "example-zone"

  # DNS record
  name    = "app.example.com."
  type    = "CNAME"
  ttl     = 300
  rrdatas = ["${module.aws-tempest.ingress_dns_name}."]
}
```

## Digital Ocean

On Digital Ocean, a DNS A record (e.g. `nemo-workers.example.com`) resolves to each worker[^1] running an Ingress controller DaemonSet on host ports 80 and 443. Firewall rules allow IPv4 and IPv6 traffic to ports 80 and 443.

Create the Ingress controller daemonset, service, RBAC roles, RBAC bindings, default backend, and namespace.

```
kubectl apply -R -f addons/nginx-ingress/digital-ocean
```

For each application, add a CNAME record resolving to the worker(s) DNS record. Use the Typhoon module's output `workers_dns` to find the worker DNS value. For example, you might use Terraform to manage a Google Cloud DNS record:

```tf
resource "google_dns_record_set" "some-application" {
  # DNS zone name
  managed_zone = "example-zone"

  # DNS record
  name    = "app.example.com."
  type    = "CNAME"
  ttl     = 300
  rrdatas = ["${module.digital-ocean-nemo.workers_dns}."]
}
```

[^1]: Digital Ocean does offers load balancers. We've opted not to use them to keep the Digital Ocean setup simple and cheap for developers.

## Google Cloud

On Google Cloud, a network load balancer distributes traffic across worker nodes (i.e. a target pool of backends) running an Ingress controller deployment on host ports 80 and 443. Firewall rules allow traffic to ports 80 and 443. Health check rules ensure the target pool only includes worker nodes with a healthy Nginx Ingress controller.

Create the Ingress controller deployment, service, RBAC roles, RBAC bindings, default backend, and namespace.

```
kubectl apply -R -f addons/nginx-ingress/google-cloud
```

For each application, add a DNS record resolving to the network load balancer's IPv4 address.

```
app1.example.com -> 11.22.33.44
aap2.example.com -> 11.22.33.44
app3.example.com -> 11.22.33.44
```

Find the IPv4 address with `gcloud compute addresses list` or use the Typhoon module's output `ingress_static_ip`. For example, you might use Terraform to manage a Google Cloud DNS record:

```tf
resource "google_dns_record_set" "some-application" {
  # DNS zone name
  managed_zone = "example-zone"

  # DNS record
  name    = "app.example.com."
  type    = "A"
  ttl     = 300
  rrdatas = ["${module.google-cloud-yavin.ingress_static_ip}"]
}
```

## Bare-Metal

On bare-metal, routing traffic to Ingress controller pods can be done in number of ways.

### Equal-Cost Multi-Path

Deploy the Nginx Ingress Controller as a deployment. Deploy the service with a fixed ClusterIP (e.g. 10.3.0.12) in the Kubernetes service IPv4 CIDR range. There is no need for a NodePort or for pods to bind host ports. Any node can proxy packets destined for the service's ClusterIP to a node which has a pod endpoint.

Configure the network router or load balancer with a static route for the Kubernetes service range and set the next hop to a node. Repeat for each node and set the metric (i.e. cost) of each. Finally, DNAT traffic destined for the WAN on ports 80 or 443 to the service's fixed ClusterIP.

Add a DNS record resolving to the WAN for each application.

```tf
resource "google_dns_record_set" "some-application" {
  # Managed DNS Zone name
  managed_zone = "zone-name"

  # Name of the DNS record
  name    = "app.example.com."
  type    = "A"
  ttl     = 300
  rrdatas = ["SOME-WAN-IP"]
}
```
