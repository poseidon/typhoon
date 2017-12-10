# Kubernetes Dashboard

!!! warning
    The Kubernetes Dashboard takes [unusual approaches](https://github.com/kubernetes/dashboard/wiki/Access-control#authorization-header) to security and is often a point of security escalations. We recommend you do don't deploy it and get familiar with `kubectl`, if possible.

The Kubernetes [Dashboard](https://github.com/kubernetes/dashboard) provides a web UI to manage a Kubernetes cluster for those who prefer an alternative to `kubectl`.

## Create

Create the dashboard deployment and service.

```
kubectl apply -f addons/dashboard -R
```

## Access

Use `kubectl` to authenticate to the apiserver and create a local port forward to the remote port on the dashboard pod.

```sh
kubectl get pods -n kube-system
kubectl port-forward POD [LOCAL_PORT:]REMOTE_PORT
kubectl port-forward kubernetes-dashboard-id 9090 -n kube-system
```

!!! tip
    If you'd like to expose the Dashboard via Ingress and add authentication, use a suitable OAuth2 proxy sidecar and pick your favorite OAuth2 provider.
