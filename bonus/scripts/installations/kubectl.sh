#!/bin/bash
set -euo pipefail

# -------------------------------
# Install kubectl
# -------------------------------
echo "⚙️ Installing kubectl..."

# Determine installation directory
if [ "$(id -u)" -eq 0 ]; then
    INSTALL_DIR="/usr/local/bin"
else
    INSTALL_DIR="$HOME/.local/bin"
    mkdir -p "$INSTALL_DIR"
fi


# Check if kubectl exists either in PATH or in the install directory
if ! command -v kubectl &> /dev/null && [ ! -x "$INSTALL_DIR/kubectl" ]; then
    echo "🚀 kubectl not found. Installing..."
    
    # Get latest stable version
    KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
    
    # Download kubectl
    curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
    
    # Make executable and move to install directory
    chmod +x kubectl
    install -o "$(id -u)" -g "$(id -g)" -m 0755 kubectl "$INSTALL_DIR/kubectl"
    rm -f kubectl

    echo "✅ kubectl installed to $INSTALL_DIR"
else
    echo "✅ kubectl already installed at $(command -v kubectl)"
fi

# Ensure INSTALL_DIR is in PATH for non-root users
if [ "$(id -u)" -ne 0 ]; then
    if ! echo "$PATH" | tr ':' '\n' | grep -qx "$INSTALL_DIR"; then
        echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$HOME/.bashrc"
        export PATH="$INSTALL_DIR:$PATH"
        echo "✅ Added $INSTALL_DIR to PATH for this session and future shells"
    else
        echo "✅ $INSTALL_DIR already in PATH"
    fi
fi

# Verify installation
echo "🔍 Verifying kubectl installation..."
kubectl version --client --output=yaml
