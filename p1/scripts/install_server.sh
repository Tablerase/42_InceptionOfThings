
#!/bin/bash
set -e

# ------------------------
# Update system and install dependencies
# ------------------------
sudo apt-get update -y
sudo apt-get upgrade -y

# Install dependencies
sudo apt-get install -y curl


# ------------------------
# Disable firewall (ufw)
# ------------------------
if sudo ufw status | grep -q "active"; then
    sudo ufw disable
    echo "Firewall disabled"
else
    echo "Firewall already inactive"
fi

# When you install K3s without K3S_URL and K3S_TOKEN,The node becomes a server node (master / control plane).
# Install K3s server (this will be our control plane node)
# It runs the control plane components: API server, scheduler, controller manager, etc.
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server \
  --node-ip=192.168.56.110 \
  --bind-address=192.168.56.110 \
  --advertise-address=192.168.56.110" sh -

# # Make sure kubectl is set up for the vagrant user
# sudo mkdir -p /home/vagrant/.kube
# sudo cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
# sudo chown -R vagrant:vagrant /home/vagrant/.kube/config


# # Get the token for the worker nodes
# TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token)
# # Store the token for the workers to use
# echo $TOKEN > /vagrant/confs/node-token

# Ensure the shared folder exists
sudo mkdir -p /vagrant/.confs
sudo chown vagrant:vagrant /vagrant/.confs

# Extract join token for worker and fix permissions
sudo cp /var/lib/rancher/k3s/server/node-token /vagrant/.confs/node-token
sudo chown vagrant:vagrant /vagrant/.confs/node-token
sudo chmod 644 /vagrant/.confs/node-token

echo "✅ K3s server installation completed. Node token is ready for workers."
