# horizontal pod autoscaling

## metrics server is required

What is Metrics Server?

Metrics Server is a cluster-wide aggregator of resource usage data in Kubernetes. It collects metrics like CPU and memory usage from each node's kubelet (the agent running on each node) and exposes them through the Kubernetes API.Why is it needed?The Horizontal Pod Autoscaler (HPA) needs real-time CPU/memory metrics to make scaling decisions. Without Metrics Server:

HPA can't see how much CPU/memory pods are using
You get errors like unable to get metrics for resource cpu
`kubectl top` commands don't work

### install metrics server (on Docker k8s, minikube, kind)

ℹ️ Metrics Server needs to talk to the kubelet on each node (port 10250)

This connection uses HTTPS with TLS certificates
In production clusters (EKS, GKE, AKS), the kubelet certificates are properly signed and include the node's IP address

In local development clusters (Docker Desktop, minikube, kind, k3s), the kubelet certificates are often self-signed and don't include IP addresses in their Subject Alternative Names (SANs)

The Solution:
The `--kubelet-insecure-tls` flag tells Metrics Server:

"Don't verify the kubelet's TLS certificate - just trust it"

This is safe for local development but should never be used in production because it disables security validation.


```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

kubectl patch deployment metrics-server -n kube-system --type='json' -p='[
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/args/-",
    "value": "--kubelet-insecure-tls"
  }
]'
```

## provision nginx deployment + autoscaling

```bash
kubectl apply -f deployment.yml

kubectl apply -f horizontal-pod-autoscaler.yml
```

## watch HPA status on a separate terminal

```bash
kubectl get hpa nginx-hpa --watch
```

## watch nginx pods scaling out and back in on a separate terminal

```bash
kubectl get pods --watch
```

## start generating load on the nginx pod

```bash
kubectl apply -f load-generator.yml
```

once the pods have scaled out completely, stop the load-generator:

```bash
kubectl delete -f load-generator.yml
````

and watch the pods scale down after a while