#!/bin/bash
set -euo pipefail

# -------------------------------------
# Install k3d via official script
# -------------------------------------
echo "📦 Installing K3d..."
# source: https://k3d.io/stable/#installation
if ! command -v k3d &> /dev/null; then
  curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

  # # Verify k3d installation
  echo ">>> Verifying k3d installation..."
  k3d version || true

  echo "✅ Installation completed! You now have k3s and k3d installed."
else
  echo "✅ 3d already installed."
  k3d version || true
fi

