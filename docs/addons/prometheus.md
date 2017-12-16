# Prometheus

Prometheus collects metrics (e.g. `node_memory_usage_bytes`) from *targets* by scraping their HTTP metrics endpoints. Targets are organized into *jobs*, defined in the Prometheus config. Targets may expose counter, gauge, histogram, or summary metrics.

Here's a simple config from the Prometheus [tutorial](https://prometheus.io/docs/introduction/getting_started/).

```
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']
```

On Kubernetes clusters, Prometheus is run as a Deployment, configured with a ConfigMap, and accessed via a Service or Ingress.

```
kubectl apply -f addons/prometheus -R
```

The ConfigMap configures Prometheus to target apiserver endpoints, node metrics, cAdvisor metrics, and exporters. By default, data is kept in an `emptyDir` so it is persisted until the pod is rescheduled.

### Exporters

Exporters expose metrics for 3rd-party systems that don't natively expose Prometheus metrics.

* [node_exporter](https://github.com/prometheus/node_exporter) - DaemonSet that exposes a machine's hardware and OS metrics
* [kube-state-metrics](https://github.com/kubernetes/kube-state-metrics) - Deployment that exposes Kubernetes object metrics
* [blackbox_exporter](https://github.com/prometheus/blackbox_exporter) - Scrapes HTTP, HTTPS, DNS, TCP, or ICMP endpoints and exposes availability as metrics

### Queries and Alerts

Prometheus provides a simplistic UI for querying metrics and viewing alerts. Use `kubectl` to authenticate to the apiserver and create a local port-forward to the Prometheus pod.

```
kubectl get pods -n monitoring
kubectl port-forward prometheus-POD-ID 9090 -n monitoring
```

Visit [127.0.0.1:9090](http://127.0.0.1:9090) to query [expressions](http://127.0.0.1:9090/graph), view [targets](http://127.0.0.1:9090/targets), or check [alerts](http://127.0.0.1:9090/alerts).

![Prometheus Graph](/img/prometheus-graph.png)
<br/>
![Prometheus Targets](/img/prometheus-targets.png)
<br/>
![Prometheus Alerts](/img/prometheus-alerts.png)

## Grafana

Grafana can be used to build dashboards and rich visualizations that use Prometheus as the datasource. Create the grafana deployment and service.

```
kubectl apply -f addons/grafana -R
```

Use `kubectl` to authenticate to the apiserver and create a local port-forward to the Grafana pod.

```
kubectl port-forward grafana-POD-ID 8080 -n monitoring
```

Visit [127.0.0.1:8080](http://127.0.0.1:8080), add the prometheus data-source (http://prometheus.monitoring.svc.cluster.local), and import your desired dashboard (e.g. [Grafana Dashboard 315](https://grafana.com/dashboards/315)).

![Grafana Dashboard](/img/grafana-dashboard.png)

