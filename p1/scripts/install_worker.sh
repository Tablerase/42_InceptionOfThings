#!/bin/bash
set -e

# Update system
sudo apt-get update -y
sudo apt-get upgrade -y

# Install dependencies
sudo apt-get install -y curl

# Server IP
SERVER_IP="192.168.56.110"

# sudo systemctl stop k3s-agent
# sudo rm -rf /etc/rancher/k3s /var/lib/rancher/k3s

curl -sfL https://get.k3s.io | \
  INSTALL_K3S_EXEC="agent" \
  K3S_URL="https://192.168.56.110:6443" \
  K3S_TOKEN="$(cat /vagrant/.confs/node-token)" \
  K3S_NODE_IP="192.168.56.111" \
  sh -
# Make kubectl available for vagrant user (optional)
# sudo mkdir -p /home/vagrant/.kube
# sudo cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config || true
# sudo chown -R vagrant:vagrant /home/vagrant/.kube/config

echo "✅ K3s worker installation completed and should join the cluster."





######################################################################################################################################
######################################################################################################################################



# #!/bin/bash
# set -e

# # ------------------------
# # Update system and install dependencies
# # ------------------------
# sudo apt-get update -y
# sudo apt-get upgrade -y
# sudo apt-get install -y curl

# # ------------------------
# # Disable firewall (ufw)
# # ------------------------
# if sudo ufw status | grep -q "active"; then
#     sudo ufw disable
#     echo "✅ Firewall disabled"
# else
#     echo "✅ Firewall already inactive"
# fi

# # ------------------------
# # Wait for node-token from server
# # ------------------------
# while [ ! -f /vagrant/confs/node-token ]; do
#     echo "⏳ Waiting for node-token from server..."
#     sleep 2
# done

# echo $(cat /vagrant/confs/node-token)
# sudo cp /vagrant/confs/node-token /tmp/node-token

# TOKEN=$(cat /tmp/node-token | tr -d '\n')
# # TOKEN=$(cat /vagrant/confs/node-token)
# SERVER_IP=$1

# # ------------------------
# # Clean previous K3s agent installation
# # ------------------------
# # if [ -f /usr/local/bin/k3s ]; then
# #     echo "🧹 Removing previous K3s installation..."
# #     sudo /usr/local/bin/k3s-agent-uninstall.sh || true
# # fi

# # sudo rm -rf /var/lib/rancher/k3s /etc/rancher/k3s
# # sudo rm -f /etc/systemd/system/k3s-agent.service
# # sudo systemctl daemon-reload

# # ------------------------
# # Install K3s agent
# # ------------------------
# echo "⚡ Installing K3s agent..."
# curl -sfL https://get.k3s.io | \
# K3S_URL="https://$SERVER_IP:6443" \
# K3S_TOKEN="$TOKEN" \
# sh -


# # ------------------------
# # Reload systemd and restart agent
# # ------------------------
# # sudo systemctl daemon-reexec
# # sudo systemctl restart k3s-agent

# echo "✅ K3s worker installation completed. Node should now be connected to the cluster."

# # ------------------------
# # Tail logs
# # ------------------------
# # sudo journalctl -u k3s-agent -f --no-pager
