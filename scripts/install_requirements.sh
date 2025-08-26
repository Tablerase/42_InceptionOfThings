#!/bin/bash
set -euo pipefail

echo "🔧 Updating system packages..."
sudo apt-get update -y && sudo apt-get upgrade -y

# -------------------------------
# Install Docker
# -------------------------------
echo "🐳 Installing Docker..."
# https://docs.docker.com/engine/install/ubuntu/
if ! command -v docker &> /dev/null; then
    # Add Docker's official GPG key:
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    # Add the repository to Apt sources:
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    # Install the latest version
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
else
    echo "✅ Docker already installed."
fi


# -------------------------------
# Install kubectl
# -------------------------------
echo "⚙️ Installing kubectl..."
# Download the latest stable kubectl release
# https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"

# Check if user has root privileges
if [ "$(id -u)" -eq 0 ]; then
  echo ">>> Installing kubectl system-wide..."
  install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
else
  echo ">>> Installing kubectl in ~/.local/bin..."
  chmod +x kubectl
  mkdir -p ~/.local/bin
  mv ./kubectl ~/.local/bin/kubectl

  # Ensure ~/.local/bin is in PATH
  if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc
    echo ">>> Added ~/.local/bin to PATH (restart your shell or run 'source ~/.bashrc')"
  fi
fi

# Verify kubectl installation
echo ">>> Verifying kubectl installation..."
kubectl version --client --output=yaml || true


# -------------------------------
# Install K3d
# -------------------------------
echo "📦 Installing K3d..."
# Install k3d via official script
# https://k3d.io/stable/#installation
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Verify k3d installation
echo ">>> Verifying k3d installation..."
k3d version || true

echo "✅ Installation completed! You now have kubectl (${KUBECTL_VERSION}) and k3d installed."


# -------------------------------------------------------
# Create a local Kubernetes cluster with k3d
# -------------------------------------------------------
echo "🚀 Creating a K3d cluster..."
if ! k3d cluster list | grep -q "Wil-cluster"; then
    # k3d cluster create iot-cluster --servers 1 --agents 0 -p "8888:30080@loadbalancer"
    k3d cluster create Wil-cluster --servers 1 --agents 0 
    echo "✅ K3d cluster 'Wil-cluster' already exists."
fi


# ---------------------------------------------
# Configure kubectl to use the cluster
# ---------------------------------------------
echo "⚙️ Configuring kubectl..."
mkdir -p ~/.kube
k3d kubeconfig get Wil-cluster > ~/.kube/config
kubectl config use-context k3d-Wil-cluster

# Verify
kubectl get nodes || echo "⚠️ kubectl could not reach the cluster"


# -------------------------------
# Create namespaces
# -------------------------------
echo "📂 Creating namespaces..."
kubectl create namespace dev 2>/dev/null || echo "Namespace dev already exists."
kubectl create namespace argocd 2>/dev/null || echo "Namespace argocd already exists."

# --------------------------------------------
# Deploying Argo CD
# This sets up all the components
# —including the API server and web UI—
# inside the argocd namespace.
# --------------------------------------------
echo "📥 Deploying Argo CD..."
# https://argo-cd.readthedocs.io/en/stable/
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml


# Wait for Argo CD pods to be ready
# ---------------------------------------------
echo "⏳ Waiting for Argo CD pods to be ready..."
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s

# Verify pods status
kubectl get pods -n argocd

# -------------------------------------------------------------------
# Access the Argo CD API Server (which serves the UI)
# ArgoCD server runs internally. Let’s expose it:
# You can connect via one of several method
# Option A: Port Forwarding (quickest for local usage)
# open your browser to: https://localhost:8080
# -------------------------------------------------------------------
echo "🚀 Port-forwarding Argo CD server to https://localhost:8080..."
kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null 2>&1 &

# -------------------------------------------------------------------
# Retrieve the initial admin password & log in to the UI
# Use the username admin and that password to log in via 
# the Argo CD UI at https://localhost:8080
# -------------------------------------------------------------------
echo "🔑 Retrieving Argo CD admin password..."
ARGOGU_ADMIN_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d)
echo "✅ Argo CD admin password: $ARGOCLI_ADMIN_PASSWORD"
echo "You can now log in at: https://localhost:8080 with username 'admin'."


# ------------------------------------------------
# Install and use the Argo CD CLI
# ------------------------------------------------
echo "📦 Installing Argo CD CLI!"
# https://github.com/argoproj/argo-cd/releases/tag/v3.0.13
curl -sSL -o argocd \
  https://github.com/argoproj/argo-cd/releases/download/v3.0.13/argocd-linux-amd64
sudo install -m 555 argocd /usr/local/bin/argocd

echo "🔑 admin's pass!"
ARGOCLI_ADMIN_PASSWORD=$(argocd admin initial-password -n argocd)

echo "✅ Argo CD CLI password: $ARGOCLI_ADMIN_PASSWORD"
echo "You can now intract with argocd: argocd login localhost:8080 --username admin --password <password> --insecure"


echo "🎉 Requirements Installation Complete!"
