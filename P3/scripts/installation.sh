#!/bin/bash
set -euo pipefail

# echo "🔧 Updating system packages..."
# sudo apt-get update -y && sudo apt-get upgrade -y

# USER="${USER:-$(whoami)}"

# # -------------------------------
# # Install Docker
# # -------------------------------
# echo "🐳 Installing Docker..."
# # source: https://docs.docker.com/engine/install/ubuntu/
# if ! command -v docker &> /dev/null; then
#   # Uninstall conflicting packages
#   echo "🔧 Removing conflicting packages..."
#   for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
#     sudo apt-get remove -y "$pkg" || true
#   done

#   # Clean up any residual Docker data
#   echo "🧹 Cleaning up Docker data..."
#   sudo rm -rf /var/lib/docker /etc/docker

#   # Update package index
#   echo "🔄 Updating package index..."
#   sudo apt-get update

#   # Install required packages
#   echo "📦 Installing required packages..."
#   sudo apt-get install -y \
#     ca-certificates \
#     curl \
#     gnupg \
#     lsb-release \
#     apt-transport-https

#   # Add Docker's official GPG key
#   echo "🔑 Adding Docker's official GPG key..."
#   sudo install -m 0755 -d /etc/apt/keyrings
#   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
#     sudo tee /etc/apt/keyrings/docker.asc > /dev/null

#   # Add Docker repository
#   echo "📦 Adding Docker repository..."
#   echo \
#     "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
#     $(lsb_release -cs) stable" | \
#     sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

#   # Update package index again
#   echo "🔄 Updating package index..."
#   sudo apt-get update

#   # Install Docker packages
#   echo "🐳 Installing Docker Engine..."
#   sudo apt-get install -y \
#     docker-ce \
#     docker-ce-cli \
#     containerd.io \
#     docker-buildx-plugin \
#     docker-compose-plugin || true

#   # Add user to docker group
#   echo "👥 Adding user '$USER' to the docker group..."
#   sudo usermod -aG docker "$USER" || true
#   # Activate the new group in the current shell
#   # exec sg docker newgrp

#   # Verify Docker installation
#   echo "✅ Verifying Docker installation..."
#   sudo docker run hello-world || true

#   echo "🎉 Docker installation completed successfully!"
#   echo "Docker version: $(docker --version || echo 'Check with sudo if needed')"
#   echo "⚠️ You may need to log out and log back in for Docker works without sudo."

# else
#     echo "✅ Docker already installed."
#     echo "Docker version: $(docker --version || echo 'Check with sudo if needed')"
#     echo "⚠️ You may need to log out and log back in for Docker works without sudo."
# fi



# # -------------------------------
# # Install kubectl
# # -------------------------------
# echo "⚙️ Installing kubectl..."
# # source: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
# if ! command -v kubectl &> /dev/null; then
#     KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
#     curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"

#     if [ "$(id -u)" -eq 0 ]; then
#         echo ">>> Installing kubectl system-wide..."
#         install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
#     else
#         echo ">>> Installing kubectl in ~/.local/bin..."
#         chmod +x kubectl
#         mkdir -p "$HOME/.local/bin"
#         mv ./kubectl ~/.local/bin/kubectl

#         # Add to PATH immediately for this script
#         export PATH="$HOME/.local/bin:$PATH"

#         # Check if ~/.local/bin is already in ~/.bashrc
#         if ! grep -q 'export PATH=$HOME/.local/bin:$PATH' "$HOME/.bashrc"; then
#             echo 'export PATH=$HOME/.local/bin:$PATH' >> "$HOME/.bashrc"
#             echo ">>> Added ~/.local/bin to PATH in ~/.bashrc (will apply in new terminals)"
#         fi
#     fi  # <-- closes the root vs non-root check

#     # Verify kubectl installation (runs for both root and non-root)
#     echo ">>> Verifying kubectl installation..."
#     kubectl version --client --output=yaml || true
# else
#     echo "✅ kubectl already installed."
#     kubectl version --client --output=yaml || true
# fi




# # -------------------------------------
# # Install k3d via official script
# # -------------------------------------
# echo "📦 Installing K3d..."
# # source: https://k3d.io/stable/#installation
# if ! command -v k3d &> /dev/null; then
#   curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

#   # # Verify k3d installation
#   echo ">>> Verifying k3d installation..."
#   k3d version || true

#   echo "✅ Installation completed! You now have k3s and k3d installed."
# else
#   echo "✅ 3d already installed."
#   k3d version || true
# fi


# # -------------------------------------------------------
# # Create a local Kubernetes cluster with k3d
# # -------------------------------------------------------
# echo "🚀 Creating a K3d cluster..."
# if ! k3d cluster list | grep -q "Wil-cluster"; then
#     # # Port-forwarding is temporary
#     k3d cluster create Wil-cluster --servers 1 --agents 0 -p "8888:30080@server:0"
#     # k3d cluster create Wil-cluster --servers 1 --agents 0
#     echo "✅ K3d cluster 'Wil-cluster' created."
# else
#     echo "✅ K3d cluster 'Wil-cluster' already exists"
# fi


# # ---------------------------------------------
# # Configure kubectl to use the cluster
# # ---------------------------------------------
# echo "⚙️ Configuring kubectl..."
# mkdir -p ~/.kube
# k3d kubeconfig get Wil-cluster > ~/.kube/config
# # Optional: set KUBECONFIG env variable for current session (ensures kubectl uses it immediately)
# export KUBECONFIG="$HOME/.kube/config"
# kubectl config use-context k3d-Wil-cluster

# # Verify
# kubectl get nodes || echo "⚠️ kubectl could not reach the cluster"


# # -------------------------------
# # Create namespaces
# # -------------------------------
# echo "📂 Creating namespaces..."
# kubectl create namespace dev 2>/dev/null || echo "Namespace dev already exists."
# kubectl create namespace argocd 2>/dev/null || echo "Namespace argocd already exists."

# # --------------------------------------------
# # Deploying Argo CD
# # This sets up all the components
# # —including the API server and web UI—
# # inside the argocd namespace.
# # --------------------------------------------
# echo "📥 Deploying Argo CD..."
# # source: https://argo-cd.readthedocs.io/en/stable/
# kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml


# # Wait for Argo CD pods to be ready
# # ---------------------------------------------
# echo "⏳ Waiting for Argo CD pods to be ready..."
# kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s

# echo "✅ Verify pods status"
# kubectl get pods -n argocd

# # -------------------------------------------------------------------
# # Access the Argo CD API Server (which serves the UI)
# # ArgoCD server runs internally. Let’s expose it:
# # You can connect via one of several method
# # Option A: Port Forwarding (quickest for local usage)
# # open your browser to: https://localhost:8080
# # -------------------------------------------------------------------
# echo "🚀 Port-forwarding Argo CD server to https://localhost:8080..."
# kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null 2>&1 &

# # echo "🚀 Port-forwarding app service to https://localhost:8888..."
# # kubectl port-forward svc/wil-playground-service -n dev 8888:8888 > /dev/null 2>&1 &

# # kubectl -n kube-system port-forward svc/traefik 8888:80 > /dev/null 2>&1 &

# # echo "🚀 Port-forwarding app service to https://localhost:30080..."
# # kubectl port-forward svc/wil-playground-service -n dev 30080:8888 > /dev/null 2>&1 &

# # -------------------------------------------------------------------
# # Retrieve the initial admin password & log in to the UI
# # Use the username admin and that password to log in via 
# # the Argo CD UI at https://localhost:8080
# # -------------------------------------------------------------------
# echo "🔑 Retrieving Argo CD admin password..."
# ARGOGU_ADMIN_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret \
#   -o jsonpath="{.data.password}" | base64 -d)
# echo "✅ Argo CD admin password: $ARGOGU_ADMIN_PASSWORD"
# echo "You can now log in at: https://localhost:8080 with username 'admin'."


# # ------------------------------------------------
# # Install and use the Argo CD CLI
# # ------------------------------------------------
# echo "📦 Installing Argo CD CLI!"
# # source: https://github.com/argoproj/argo-cd/releases/tag/v3.0.13
# curl -sSL -o argocd \
#   https://github.com/argoproj/argo-cd/releases/download/v3.0.13/argocd-linux-amd64
# sudo install -m 555 argocd /usr/local/bin/argocd

# echo "🔑 temporary admin password!"
# ARGOCLI_ADMIN_PASSWORD=$(argocd admin initial-password -n argocd)

# echo "✅ Argo CD CLI password: $ARGOCLI_ADMIN_PASSWORD"
# echo "You can now intract with argocd"
# echo "🔑 argocd login localhost:8080 --username admin --password <password> --insecure "
# echo "⚠️ after loging change password with: argocd account update-password"
# echo "🚪 argocd logout localhost:8080"

# echo "🎉 Requirements Installation Complete!"
