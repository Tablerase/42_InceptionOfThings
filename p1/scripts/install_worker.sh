#!/bin/bash
set -e

# Update system
sudo apt-get update -y
sudo apt-get upgrade -y

# Install dependencies
sudo apt-get install -y curl

#### istallation with environment variables
# curl -sfL https://get.k3s.io | \
#   INSTALL_K3S_EXEC="agent" \
#   K3S_URL="https://192.168.56.110:6443" \
#   K3S_TOKEN="$(cat /vagrant/.confs/node-token)" \
#   K3S_NODE_IP="192.168.56.111" \
#   sh -

export NODE_IP=192.168.56.111
export SERVER_IP=192.168.56.110

export K3S_URL="https://$SERVER_IP:6443"
export K3S_TOKEN=$(cat /vagrant/.confs/node-token)
export INSTALL_K3S_EXEC="agent --node-ip=$NODE_IP"

curl -sfL https://get.k3s.io | sh -

echo "✅ K3s worker installation completed and should join the cluster."
