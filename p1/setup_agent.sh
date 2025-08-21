#!/usr/bin/bash
set -euo pipefail

# Install K3S Agent
# K3S Env vars: https://docs.k3s.io/reference/env-variables
# K3S Agent: https://docs.k3s.io/cli/agent
# K3S Config: https://docs.k3s.io/installation/configuration#configuration-file

# Create a directory for the K3S configuration
mkdir -p /etc/rancher/k3s
cp /vagrant/k3s-agent-config.yaml /etc/rancher/k3s/config.yaml

# Install and run the agent 
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent" sh -

# Check k3s status
kubectl get nodes -o wide

