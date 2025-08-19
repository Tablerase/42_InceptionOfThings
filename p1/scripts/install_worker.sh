# #!/bin/bash
# set -e

# # Update system
# sudo apt-get update -y
# sudo apt-get upgrade -y

# # Install dependencies
# sudo apt-get install -y curl

# while [ ! -f /vagrant/confs/node-token ]; do
#     echo "Waiting for node-token..."
#     sleep 2
# done

# # Clean any previous agent installation:
# # sudo systemctl stop k3s-agent
# # sudo /usr/local/bin/k3s-agent-uninstall.sh
# # sudo rm -rf /var/lib/rancher/k3s /etc/rancher/k3s

# # Get token from shared folder
# TOKEN=$(cat /vagrant/confs/node-token)
# #  <SERVER_IP> the IP of our Server VM
# SERVER_IP="192.168.56.110"

# # When you install K3s with K3S_URL and K3S_TOKEN,The node becomes a worker node (agent).
# # It does not run control plane components.
# # It only connects to the server and runs pods assigned by the control plane.
# # install K3s in agent mode and join it to the server node:

# # K3S_URL=https://<SERVER_IP>:6443
# # Tells the installer which server (control plane) to connect to.
# # Port 6443 is the default Kubernetes API server port.

# # $TOKEN → secret token generated on the server when K3s was installed.
# # Used to authenticate the worker node with the server.
# # Without it, the node cannot join the cluster.

# curl -sfL https://get.k3s.io | K3S_URL="https://192.168.56.110:6443" K3S_TOKEN="$TOKEN" sh -


#!/bin/bash
set -e

# Update system
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y curl

# Wait for the node-token from the server
while [ ! -f /vagrant/confs/node-token ]; do
    echo "Waiting for node-token from server..."
    sleep 2
done

# Read token and set server IP
TOKEN=$(cat /vagrant/confs/node-token)
SERVER_IP="192.168.56.110"

# Clean up any previous K3s agent installation
if [ -f /usr/local/bin/k3s ]; then
    echo "Removing previous K3s installation..."
    sudo /usr/local/bin/k3s-agent-uninstall.sh || true
fi
sudo rm -rf /var/lib/rancher/k3s /etc/rancher/k3s

# Install K3s agent
curl -sfL https://get.k3s.io | K3S_URL="https://$SERVER_IP:6443" K3S_TOKEN="$TOKEN" sh -

# Check service status
sudo systemctl daemon-reload
sudo systemctl enable k3s-agent
sudo systemctl start k3s-agent

echo "✅ K3s worker installation completed. Node has joined the cluster."
sudo systemctl status k3s-agent
