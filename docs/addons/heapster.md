# Heapster

[Heapster](https://kubernetes.io/docs/user-guide/monitoring/) collects data from apiservers and kubelets and exposes it through a REST API. This API powers the `kubectl top` command and Kubernetes dashboard graphs.

## Create

```sh
kubectl apply -f addons/heapster -R
```

## Usage

Allow heapster to run for a few minutes, then check CPU and memory usage.

```sh
kubectl top node
kubectl top pod
```

