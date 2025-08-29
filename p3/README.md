# Part 3 - ArgoCD and K3D

```bash
# kubectl system info
k get all -n kube-system
```

```bash
# Get cluster in config
kubectl config get-contexts -o name
```

```bash
# Set current namespaces to <ns>
kubectl config set-context --current --namespace=<ns>
```

## K3D

```bash
# Remove cluster
k3d cluster delete <cluster>
```
