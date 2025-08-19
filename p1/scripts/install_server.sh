
#!/bin/bash
set -e

# Update system
sudo apt-get update -y
sudo apt-get upgrade -y

# Install dependencies
sudo apt-get install -y curl

# When you install K3s without K3S_URL and K3S_TOKEN,The node becomes a server node (master / control plane).
# Install K3s server (this will be our control plane node)
# It runs the control plane components: API server, scheduler, controller manager, etc.
curl -sfL https://get.k3s.io | sh -

# TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token)

# Ensure the shared folder exists
sudo mkdir -p /vagrant/confs
sudo chown vagrant:vagrant /vagrant/confs

# Extract join token for worker and fix permissions
sudo cp /var/lib/rancher/k3s/server/node-token /vagrant/confs/node-token
sudo chown vagrant:vagrant /vagrant/confs/node-token
sudo chmod 644 /vagrant/confs/node-token

# Allow vagrant user to use kubectl
mkdir -p /home/vagrant/.kube
sudo cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
sudo chown vagrant:vagrant /home/vagrant/.kube/config
sudo chmod 644 /home/vagrant/.kube/config

echo "✅ K3s server installation completed. Node token is ready for workers."
