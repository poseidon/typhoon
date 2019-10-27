# Hardware

Typhoon ensures certain networking hardware integrates well with bare-metal Kubernetes.

## Ubiquiti

Ubiquiti EdgeRouters and EdgeOS work well with bare-metal Kubernetes clusters. Familiarity with EdgeRouter setup and CLI usage is required.

### DHCP

Assign static IPs to clients with known MAC addresses. This is called a static mapping by EdgeOS. Configure the router with the commands based on region inventory.

```
configure
show service dhcp-server shared-network
set service dhcp-server shared-network-name LAN subnet SUBNET static-mapping NAME mac-address MACADDR
set service dhcp-server shared-network-name LAN subnet SUBNET static-mapping NAME ip-address 10.0.0.20
```

### DNS

Add DNS A records to static IPs as `dnsmasq` host-records.

```
configure
set service dns forwarding options host-record=node.example.com,10.0.0.20
```

Forward `*.svc.cluster.local` queries to the CoreDNS Kubernetes service IP to allow clients to resolve Kubernetes services.

```
set service dns forwarding options server=/svc.cluster.local/10.3.0.10
commit-confirm
```

Restart `dnsmasq`.

```
sudo /etc/init.d/dnsmasq restart
```

### PXE

Ubiquiti EdgeRouters can provide a PXE-enabled network boot environment for client machines.

#### ISC DHCP

With ISC DHCP, add a subnet parameter to the LAN DHCP server to include an ISC DHCP config file.

```
configure
show service dhcp-server shared-network-name NAME subnet SUBNET
set service dhcp-server shared-network-name NAME subnet SUBNET subnet-parameters "include &quot;/config/scripts/ipxe.conf&quot;;"
commit-confirm
```

Switch to root (i.e. `sudo -i`) and write the ISC DHCP config `/config/scripts/ipxe.conf`. iPXE client machines will chainload to `matchbox.example.com`, while non-iPXE clients will chainload to `undionly.kpxe` (requires TFTP).

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

#### dnsmasq

With dnsmasq for DHCP, add options to chainload PXE clients to iPXE `undionly.kpxe` (requires TFTP), tag iPXE clients, and chainload iPXE clients to `matchbox.example.com`.

```
set service dns forwarding options 'dhcp-userclass=set:ipxe,iPXE'
set service dns forwarding options 'pxe-service=tag:#ipxe,x86PC,PXE chainload to iPXE,undionly.kpxe'
set service dns forwarding options 'pxe-service=tag:ipxe,x86PC,iPXE,http://matchbox.example.com/boot.ipxe'
```   

### TFTP

Use `dnsmasq` as a TFTP server to serve `undionly.kpxe`. Compiling from [source](https://github.com/ipxe/ipxe) with TLS support is strongly recommended. If you use a [pre-compiled](http://boot.ipxe.org/undionly.kpxe) copy, you must set `download_protocol = "http"` in your cluster definition (discouraged).

```
sudo -i
mkdir /config/tftpboot && cd /config/tftpboot
curl http://boot.ipxe.org/undionly.kpxe -o undionly.kpxe
```

Add `dnsmasq` command line options to enable the TFTP file server.

```
configure
show service dns forwarding
set service dns forwarding options enable-tftp
set service dns forwarding options tftp-root=/config/tftpboot
commit-confirm
```

### Routing

#### Static Routes

Add static route(s) to Kubernetes node(s) that can route to Kubernetes service IPs (default: 10.3.0.0/16). Kubernetes service IPs will become routeable on the LAN.

```
configure
show protocols static route
set protocols static route 10.3.0.0/16 next-hop NODE_IP
commit-confirm
```

!!! note
    Adding multiple next-hop nodes provides equal-cost multi-path (ECMP) routing. EdgeOS v2.0+ is required. The kernel in prior versions used flow-hash to balanced packets, whereas with v2.0, round-robin sessions are used.

#### BGP

EdgeRouter can exchange routes with other autonomous systems, including a cluster's Calico AS. Peers will exchange `podCIDR` routes to make individual pods routeable on the LAN.

Define the EdgeRouter AS (if undefined).

```
configure
show protocols bgp 1
set protocols bgp 1 parameters router-id ROUTER_IP
```

Peer with node(s) in another AS (eg. Calico default 64512)

```
set protocols bgp 1 neighbor NODE1_IP remote-as 64512
set protocols bgp 1 neighbor NODE2_IP remote-as 64512
set protocols bgp 1 neighbor NODE3_IP remote-as 64512
commit-confirm
```

Configure Calico node(s) as to peer with the EdgeRouter.

```
apiVersion: crd.projectcalico.org/v1
kind: BGPPeer
metadata:
  name: NODE_NAME-to-edgerouter
spec:
  peerIP: ROUTER_IP
  asNumber: 1
  node: NODE_NAME
```

Or, if every node is to be peered (i.e. full mesh), define a global BGPPeer.

```
apiVersion: crd.projectcalico.org/v1
kind: BGPPeer
metadata:
  name: global
spec:
  peerIP: ROUTER_IP
  asNumber: 1
```

If Calico nodes should advertise Kubernetes Service IPs (i.e. ClusterIPs) as well, add a `BGPConfiguration`.

```
apiVersion: crd.projectcalico.org/v1
kind: BGPConfiguration
metadata:
  name: default
spec:
  logSeverityScreen: Info
  nodeToNodeMeshEnabled: true
  serviceClusterIPs:
    - cidr: 10.3.0.0/16
```

Show a summary of peers and exchanged routes.

```
show ip bgp summary
show ip route bgp
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

