# Performance

## Provision Time

Provisioning times vary based on the platform. Sampling the time to create (apply) and destroy clusters with 1 controller and 2 workers shows (roughly) what to expect.

| Platform      | Apply | Destroy |
|---------------|-------|---------|
| AWS           | 6 min | 5 min   |
| Bare-Metal    | 10-14 min | NA  |
| Digital Ocean | 3 min 30 sec | 20 sec |
| Google Cloud  | 7 min | 4 min 30 sec |

Notes:

* SOA TTL and NXDOMAIN caching can have a large impact on provision time
* Platforms with auto-scaling take more time to provision (AWS, Google)
* Bare-metal POST times and network bandwidth will affect provision times

## Network Performance

Network performance varies based on the platform and CNI plugin. `iperf` was used to measure the bandwidth between different hosts and different pods. Host-to-host shows typical bandwidth between host machines. Pod-to-pod shows the bandwidth between two `iperf` containers.

| Platform / Plugin          | Theory | Host to Host | Pod to Pod   |
|----------------------------|-------:|-------------:|-------------:|
| AWS (flannel)              | ?      | 976 MB/s     | 900-999 MB/s |
| AWS (calico, MTU 1480)     | ?      | 976 MB/s     | 100-350 MB/s |
| AWS (calico, MTU 8991)     | ?      | 976 MB/s     | 900-999 MB/s |
| Bare-Metal (flannel)       | 1 GB/s | 934 MB/s     | 903 MB/s     | 
| Bare-Metal (calico)        | 1 GB/s | 941 MB/s     | 931 MB/s     |
| Bare-Metal (flannel, bond) | 3 GB/s |  2.3 GB/s    | 1.17 GB/s    | 
| Bare-Metal (calico, bond)  | 3 GB/s |  2.3 GB/s    | 1.17 GB/s    |
| Digital Ocean              | ?      | 938 MB/s     | 820-880 MB/s |
| Google Cloud (flannel)     | ?      | 1.94 GB/s    | 1.76 GB/s    |
| Google Cloud (calico)      | ?      | 1.94 GB/s    | 1.81 GB/s    |

Notes:

* Calico and Flannel have comparable performance. Platform and configuration differences dominate.
* Neither CNI provider seems to be able to leverage bonded NICs (bare-metal)
* AWS and Digital Ocean network bandwidth fluctuates more than on other platforms.
* Only [certain AWS EC2 instance types](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/network_mtu.html#jumbo_frame_instances) allow jumbo frames. This is why the default MTU on AWS must be 1480.
