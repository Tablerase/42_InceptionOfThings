kubectl version --client

docker --version

k3d version

sudo k3d cluster list

sudo kubectl get namespaces

Verify resources in a namespace:
    sudo kubectl get all -n argocd
    sudo kubectl get all -n dev


!when you install Argo CD in Kubernetes, what you’re really installing is a set of pods (argocd-server, argocd-repo-server, etc.) running in the cluster. Unlike a CLI tool, it doesn’t automatically print its version on install.