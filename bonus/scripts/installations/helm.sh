#!/bin/bash
set -euo pipefail

# -------------------------------
# Install Helm
# -------------------------------
echo "🐳 Installing Helm..."
# source: https://helm.sh/docs/intro/install/
if ! command -v helm &> /dev/null; then
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh

    # execute script to installe Helm
    ./get_helm.sh

    helm version
    echo "🎉 Helm installation completed successfully!"
else
    echo "✅ Helm already installed."
    echo "Helm version: $(helm version || echo 'Check with sudo if needed')"
fi

# uninstall helm
# sudo rm /usr/local/bin/helm

# rm -rf ~/.helm
# rm -rf ~/.cache/helm
