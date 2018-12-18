# Performance

## Provision Time

Provisioning times vary based on the operating system and platform. Sampling the time to create (apply) and destroy clusters with 1 controller and 2 workers shows (roughly) what to expect.

| Platform      | Apply | Destroy |
|---------------|-------|---------|
| AWS           | 6 min | 4 min   |
| Azure         | 7 min | 7 min   |
| Bare-Metal    | 10-15 min | NA  |
| Digital Ocean | 3 min 30 sec | 20 sec |
| Google Cloud  | 7 min | 6 min   |

Notes:

* SOA TTL and NXDOMAIN caching can have a large impact on provision time
* Platforms with auto-scaling take more time to provision (AWS, Azure, Google)
* Bare-metal POST times and network bandwidth will affect provision times

## Network Performance

Network performance varies based on the platform and CNI plugin. `iperf` was used to measure the bandwidth between different hosts and different pods. Host-to-host shows typical bandwidth between host machines. Pod-to-pod shows the bandwidth between two `iperf` containers.

| Platform / Plugin          | Theory | Host to Host | Pod to Pod   |
|----------------------------|-------:|-------------:|-------------:|
| AWS (flannel)              | 5 Gb/s | 4.94 Gb/s    | 4.89 Gb/s    |
| AWS (calico, MTU 1480)     | 5 Gb/s | 4.94 Gb/s    | 4.42 Gb/s    |
| AWS (calico, MTU 8981)     | 5 Gb/s | 4.94 Gb/s    | 4.75 Gb/s    |
| Azure (flannel)            | Varies |  749 Mb/s    | 680 Mb/s     |
| Bare-Metal (flannel)       | 1 Gb/s |  940 Mb/s    | 903 Mb/s     |
| Bare-Metal (calico)        | 1 Gb/s |  940 Mb/s    | 931 Mb/s     |
| Bare-Metal (flannel, bond) | 3 Gb/s |  2.3 Gb/s    | 1.17 Gb/s    |
| Bare-Metal (calico, bond)  | 3 Gb/s |  2.3 Gb/s    | 1.17 Gb/s    |
| Digital Ocean              | 2 Gb/s | 1.97 Gb/s    | 1.64 Gb/s    |
| Google Cloud (flannel)     | 2 Gb/s | 1.94 Gb/s    | 1.76 Gb/s    |
| Google Cloud (calico)      | 2 Gb/s | 1.94 Gb/s    | 1.81 Gb/s    |

Notes:

* Calico and Flannel have comparable performance. Platform and configuration differences dominate.
* AWS and Azure node bandwidth (i.e. upper bound) depends greatly on machine type
* Only [certain AWS EC2 instance types](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/network_mtu.html#jumbo_frame_instances) allow jumbo frames. This is why the default MTU on AWS must be 1480.
* Neither CNI provider seems to be able to leverage bonded NICs well (bare-metal)

