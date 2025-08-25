#!/bin/bash
set -euo pipefail

echo "🔧 Updating system packages..."
sudo apt-get update -y && sudo apt-get upgrade -y

# -------------------------------
# Install Docker
# -------------------------------
echo "🐳 Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | sh
    # sudo usermod -aG docker $USER
    # echo "⚠️ Please log out and log back in for Docker group changes to take effect."
else
    echo "✅ Docker already installed."
fi

# -------------------------------
# Install K3d
# -------------------------------
echo "📦 Installing K3d..."
if ! command -v k3d &> /dev/null; then
    curl -fsSL https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
else
    echo "✅ K3d already installed."
fi

# -------------------------------
# Install kubectl
# -------------------------------
echo "⚙️ Installing kubectl..."
if ! command -v kubectl &> /dev/null; then
    KUBECTL_VERSION=$(curl -fsSL https://dl.k8s.io/release/stable.txt)
    if [ -z "$KUBECTL_VERSION" ]; then
        echo "❌ Failed to fetch kubectl version."
        exit 1
    fi
    echo "⬇️ Downloading kubectl version $KUBECTL_VERSION..."
    curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" -o kubectl
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
else
    echo "✅ kubectl already installed."
fi

# -------------------------------
# Create K3d cluster
# -------------------------------
echo "🚀 Creating a K3d cluster..."
if ! k3d cluster list | grep -q "iot-cluster"; then
    k3d cluster create iot-cluster --servers 1 --agents 0
else
    echo "✅ K3d cluster 'iot-cluster' already exists."
fi

# -------------------------------
# Create namespaces
# -------------------------------
echo "📂 Creating namespaces..."
kubectl create namespace argocd 2>/dev/null || echo "Namespace argocd already exists."
kubectl create namespace dev 2>/dev/null || echo "Namespace dev already exists."

# -------------------------------
# nstalling Argo CD
# -------------------------------
echo "📥 Installing Argo CD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "🎉 Installation complete!"
