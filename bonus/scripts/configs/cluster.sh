#!/bin/bash
set -euo pipefail

CLUSTER_NAME=Wil-cluster
# -------------------------------------------------------
# Create a local Kubernetes cluster with k3d
# -------------------------------------------------------
echo "🚀 Creating cluster (Docker containers that act as Kubernetes nodes)..."
if ! k3d cluster list | grep -q "$CLUSTER_NAME"; then

    # # when our service is ClusterIP type we need to do portforwarding manually, it is good for testing phase
    # k3d cluster create $CLUSTER_NAME --servers 1 --agents 0
    # # kubectl port-forward svc/wil-playground-service -n dev 8888:9999 > /dev/null 2>&1 &

    # # for access localhost:8888 with ClusterIP type in service and we have ingress
    # k3d cluster create $CLUSTER_NAME --servers 1 --agents 0 -p "8888:80@loadbalancer"

    # # when our service is nodeport type - @server:0 maps to the server container,
    # for our app
    k3d cluster create $CLUSTER_NAME --servers 1 --agents 0 -p "80:80@loadbalancer" 
        # -p "8888:30080@server:0" \ # for access localhost:8888 with NodePOrt type in service
        # -p "443:443@loadbalancer" # for access argocdgu on argocd.local and argocd_cli with IngressRouteTCP yaml

    echo "✅ K3d cluster '$CLUSTER_NAME' created."
else
    echo "✅ K3d cluster '$CLUSTER_NAME' already exists"
fi

