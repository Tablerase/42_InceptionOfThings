#!/bin/bash
# Bash scripting cheat sheet: https://devhints.io/bash
# set -euo pipefail

# ================================ Project

# Project cluster
GITLAB_SSH_NODEPORT="32222"
GITLAB_SSH_CONFIG="32222"
CLUSTER_NAME="bonus-cluster"
if ! k3d cluster list | grep -q "^${CLUSTER_NAME}"; then
  echo "Creating k3d cluster ${CLUSTER_NAME}..."
  k3d cluster create ${CLUSTER_NAME} --servers 1 --agents 0 \
    --port "80:80@loadbalancer" --port "443:443@loadbalancer" 
    # --port "$GITLAB_SSH_CONFIG:$GITLAB_SSH_NODEPORT@server:0" \
    # --k3s-arg "--disable=traefik@server:0"
    # --k3s-arg "--disable=traefik@server:0" # disable default traefik
  # Merge current project config (auto created at cluster creation) with defautl config ($HOME/.kube/config)
  k3d kubeconfig merge ${CLUSTER_NAME} --kubeconfig-switch-context
else
  echo "Cluster ${CLUSTER_NAME} already exists, skipping creation."
fi

NAMESPACES=("dev" "argocd" "gitlab")
for ns in "${NAMESPACES[@]}"; do
  if ! kubectl get ns | grep -q "$ns"; then
    echo "☸️ Creating kubernetes $ns namespaces"
    kubectl create namespace $ns
  else
    echo "☸️ $ns namespaces already exists"
  fi
done


