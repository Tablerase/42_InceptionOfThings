#!/bin/bash
set -euo pipefail

CLUSTER_NAME=Wil-cluster
# ---------------------------------------------
# Configure kubectl to use the cluster
# ---------------------------------------------
echo "⚙️ Configuring kubectl..."

mkdir -p ~/.kube
k3d kubeconfig get $CLUSTER_NAME > ~/.kube/config
# Optional: set KUBECONFIG env variable for current session (ensures kubectl uses it immediately)
export KUBECONFIG="$HOME/.kube/config"
kubectl config use-context k3d-$CLUSTER_NAME

# Verify
kubectl get nodes || echo "⚠️ kubectl could not reach the cluster"

