#!/bin/bash
set -euo pipefail

USER="${USER:-$(whoami)}"

# -------------------------------
# Install Docker
# -------------------------------
echo "🐳 Installing Docker..."
# source: https://docs.docker.com/engine/install/ubuntu/
if ! command -v docker &> /dev/null; then
  echo "🔧 Updating system packages..."
  sudo apt-get update -y && sudo apt-get upgrade -y

  # Uninstall conflicting packages
  echo "🔧 Removing conflicting packages..."
  for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
    sudo apt-get remove -y "$pkg" || true
  done

  # Clean up any residual Docker data
  echo "🧹 Cleaning up Docker data..."
  sudo rm -rf /var/lib/docker /etc/docker

  # Update package index
  echo "🔄 Updating package index..."
  sudo apt-get update

  # Install required packages
  echo "📦 Installing required packages..."
  sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    apt-transport-https

  # Add Docker's official GPG key
  echo "🔑 Adding Docker's official GPG key..."
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo tee /etc/apt/keyrings/docker.asc > /dev/null

  # Add Docker repository
  echo "📦 Adding Docker repository..."
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  # Update package index again
  echo "🔄 Updating package index..."
  sudo apt-get update

  # Install Docker packages
  echo "🐳 Installing Docker Engine..."
  sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin || true

  # Add user to docker group
  echo "👥 Adding user '$USER' to the docker group..."
  sudo usermod -aG docker "$USER" || true
  # Activate the new group in the current shell
  # exec sg docker newgrp

  # Verify Docker installation
  echo "✅ Verifying Docker installation..."
  sudo docker run hello-world || true

  echo "🎉 Docker installation completed successfully!"
  echo "Docker version: $(docker --version || echo 'Check with sudo if needed')"
  echo "⚠️ You may need to log out and log back in for Docker works without sudo."

else
    echo "✅ Docker already installed."
    echo "Docker version: $(docker --version || echo 'Check with sudo if needed')"
    echo "⚠️ You may need to log out and log back in for Docker works without sudo."
fi

