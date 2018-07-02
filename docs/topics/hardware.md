# Hardware

Typhoon ensures certain networking hardware integrates well with bare-metal Kubernetes.

## Ubiquiti

Ubiquiti EdgeRouters work well with bare-metal Kubernetes clusters. Knowledge about how to setup an EdgeRouter and use the CLI is required.

### PXE

Ubiquiti EdgeRouters can provide a PXE-enabled network boot environment for client machines.

#### ISC DHCP

Add a subnet parameter to the LAN DHCP server to include an ISC DHCP config file.

```
configure
show service dhcp-server shared-network-name NAME subnet SUBNET
set service dhcp-server shared-network-name NAME subnet SUBNET subnet-parameters "include &quot;/config/scripts/ipxe.conf&quot;;"
commit-confirm
```

Switch to root (i.e. `sudo -i`) and write the ISC DHCP config `/config/scripts/ipxe.conf`. iPXE client machines will chainload to `matchbox.example.com`, while non-iPXE clients will chainload to `undionly.kpxe` (requires TFTP to be enabled).

```
allow bootp;
allow booting;
next-server ADD_ROUTER_IP_HERE;

if exists user-class and option user-class = "iPXE" {
  filename "http://matchbox.example.com/boot.ipxe";
} else {
  filename "undionly.kpxe";
}
```

### TFTP

Use `dnsmasq` as a TFTP server to serve [undionly.kpxe](http://boot.ipxe.org/undionly.kpxe).

```
sudo -i
mkdir /var/lib/tftpboot
cd /var/lib/tftpboot
curl http://boot.ipxe.org/undionly.kpxe -o undionly.kpxe
```

Add `dnsmasq` command line options to enable the TFTP file server.

```
configure
show service dns forwarding
set service dns forwarding options enable-tftp
set service dns forwarding options tftp-root=/var/lib/tftpboot
commit-confirm
```

!!! warning
    After firmware upgrades, the `/var/lib/tftpboot` directory will not exist and dnsmasq will not start properly. Repeat this process following an upgrade.

### DHCP

Assign static IPs to clients with known MAC addresses. This is called a static mapping by EdgeOS. Configure the router with the commands based on region inventory.

```
configure
show service dhcp-server shared-network
set service dhcp-server shared-network-name LAN subnet SUBNET static-mapping NAME mac-address MACADDR
set service dhcp-server shared-network-name LAN subnet SUBNET static-mapping NAME ip-address 10.0.0.20
```

### DNS

Assign DNS A records to nodes as options to `dnsmasq`.

```
configure
set service dns forwarding options host-record=node.example.com,10.0.0.20
```

Restart `dnsmasq`.

```
sudo /etc/init.d/dnsmasq restart
```

Configure queries for `*.svc.cluster.local` to be forwarded to the Kubernetes `coredns` service IP to allow hosts to resolve cluster-local Kubernetes names.

```
configure
show service dns forwarding
set service dns forwarding options server=/svc.cluster.local/10.3.0.10
commit-confirm
```

### Kubernetes Services

Add static routes for the Kubernetes IPv4 service range to Kubernetes node(s) so hosts can route to Kubernetes services (default: 10.3.0.0/16).

```
configure
show protocols static route
set protocols static route 10.3.0.0/16 next-hop NODE_IP
...
commit-confirm
```

### Port Forwarding

Expose the [Ingress Controller](/addons/ingress.md#bare-metal) by adding `port-forward` rules that DNAT a port on the router's WAN interface to an internal IP and port. By convention, a public Ingress controller is assigned a fixed service IP (e.g. 10.3.0.12).

```
configure
set port-forward wan-interface eth0
set port-forward lan-interface eth1
set port-forward auto-firewall enable
set port-forward hairpin-nat enable
set port-forward rule 1 description 'ingress http'
set port-forward rule 1 forward-to address 10.3.0.12
set port-forward rule 1 forward-to port 80
set port-forward rule 1 original-port 80
set port-forward rule 1 protocol tcp_udp
set port-forward rule 2 description 'ingress https'
set port-forward rule 2 forward-to address 10.3.0.12
set port-forward rule 2 forward-to port 443
set port-forward rule 2 original-port 443
set port-forward rule 2 protocol tcp_udp
commit-confirm
```

### Web UI

The web UI is often accessible from the LAN on ports 80/443 by default. Edit the ports to 8080 and 4443 to avoid a conflict.

```
configure
show service gui
set service gui http-port 8080
set service gui https-port 4443
commit-confirm
```

### BGP

Add the EdgeRouter as a global BGP peer for nodes in a Kubernetes cluster (requires Calico). Neighbors will exchange `podCIDR` routes and individual pods will become routable on the LAN.

Configure node(s) as BGP neighbors.

```
show protocols bgp 1
set protocols bgp 1 parameters router-id LAN_IP
set protocols bgp 1 neighbor NODE1_IP remote-as 64512
set protocols bgp 1 neighbor NODE2_IP remote-as 64512
set protocols bgp 1 neighbor NODE3_IP remote-as 64512
```

View the neighbors and exchanged routes.

```
show ip bgp neighbors
show ip route bgp
```

Be sure to register the peer by creating a Calico `BGPPeer` CRD with `kubectl apply`.

```
apiVersion: crd.projectcalico.org/v1
kind: BGPPeer
metadata:
  name: NAME
spec:
  peerIP: LAN_IP
  asNumber: 64512
```
