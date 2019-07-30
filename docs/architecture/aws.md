# AWS

## Load Balancing

![Load Balancing](/img/typhoon-aws-load-balancing.png)

### kube-apiserver

A network load balancer (NLB) distributes IPv4 TCP/6443 traffic across a target group of controller nodes with a healthy `kube-apiserver`. Clusters with multiple controllers span zones in a region to tolerate zone outages.

### HTTP/HTTPS Ingress

A network load balancer (NLB) distributes IPv4 TCP/80 and TCP/443 traffic across two target groups of worker nodes with a healthy Ingress controller. Workers span the zones in a region to tolerate zone outages.

The AWS NLB has a DNS alias record (regional) resolving to 3 zonal IPv4 addresses. The alias record is output as `ingress_dns_name` for use in application DNS CNAME records. See [Ingress on AWS](/addons/ingress/#aws).

### TCP Services

Load balance TCP applications by adding a listener and target group. A listener and target group may map different ports (e.g 3333 external, 30333 internal).

```tf
# Forward TCP traffic to a target group
resource "aws_lb_listener" "some-app" {
  load_balancer_arn = module.tempest.nlb_id
  protocol          = "TCP"
  port              = "3333"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.some-app.arn
  }
}

# Target group of workers for some-app
resource "aws_lb_target_group" "some-app" {
  name        = "some-app"
  vpc_id      = module.tempest.vpc_id
  target_type = "instance"

  protocol = "TCP"
  port     = 3333

  health_check {
    protocol = "TCP"
    port     = 30333
  }
}
```

Pass `worker_target_groups` to the cluster to register worker instances into custom target groups.

```tf
module "tempest" {
...
  worker_target_groups = [
    aws_lb_target_group.some-app.id,
  ]
}
```

Notes:

* AWS NLBs and target groups do not support UDP
* Global Accelerator does support UDP, but its expensive

## Firewalls

Add firewall rules to the worker security group.

```tf
resource "aws_security_group_rule" "some-app" {
  security_group_id = module.tempest.worker_security_groups[0]

  type        = "ingress"
  protocol    = "tcp"
  from_port   = 3333
  to_port     = 30333
  cidr_blocks = ["0.0.0.0/0"]
}
```

## IPv6

AWS Network Load Balancers do not support `dualstack`.

| IPv6 Feature            | Supported |
|-------------------------|-----------|
| Node IPv6 address       | Yes       |
| Node Outbound IPv6      | Yes       |
| Kubernetes Ingress IPv6 | No        |

