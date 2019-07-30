# Bare-Metal

## Load Balancing

### kube-apiserver

Load balancing across controller nodes with a healthy `kube-apiserver` is determined by your unique bare-metal environment and its capabilities.

### HTTP/HTTPS Ingress

Load balancing across worker nodes with a healthy Ingress Controller is determined by your unique bare-metal environment and its capabilities.

See the `nginx-ingress` addon to run [Nginx as the Ingress Controller](/addons/ingress/#bare-metal) for bare-metal.

### TCP/UDP Services

Load balancing across worker nodes with TCP/UDP services is determined by your unique bare-metal environment and its capabilities.

## IPv6

Status of IPv6 on Typhoon bare-metal clusters.

| IPv6 Feature            | Supported |
|-------------------------|-----------|
| Node IPv6 address       | Yes       |
| Node Outbound IPv6      | Yes       |
| Kubernetes Ingress IPv6 | Possible  |

IPv6 support depends upon the bare-metal network environment.
