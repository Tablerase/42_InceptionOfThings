#!/usr/bin/bash
set -euo pipefail

# Install K3S Server
# Kubectl (auto installed by k3s install script): https://docs.k3s.io/quick-start#install-script
# K3S Env vars: https://docs.k3s.io/reference/env-variables
# K3S Server: https://docs.k3s.io/cli/server
# K3S Config: https://docs.k3s.io/installation/configuration#configuration-file

# Create a directory for the K3S configuration
mkdir -p /etc/rancher/k3s
cp /vagrant/k3s-server-config.yaml /etc/rancher/k3s/config.yaml


# Install and run the server
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server" sh -

# Point kubectl to the k3s kubeconfig (optional if using 'k3s kubectl')
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

echo "Waiting for server node to become Ready..."
for i in {1..30}; do
  if kubectl get nodes 2>/dev/null | grep -q 'Ready'; then
    break
  fi
  sleep 2
done

# Check k3s status
kubectl get nodes -o wide || k3s kubectl get nodes -o wide

