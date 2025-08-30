#!/bin/bash
set -eu

# ---------------------------------------
# Execute all installation scripts
# ---------------------------------------

SCRIPTS=(
    "docker.sh"
    "kubectl.sh"
    "k3d.sh"
    "helm.sh"
)


for SCRIPT in "${SCRIPTS[@]}"; do
    if [ -f "$SCRIPT" ]; then
        echo "🚀 Running $SCRIPT..."
        bash "$SCRIPT"
        echo "✅ Finished $SCRIPT"
    else
        echo "⚠️  $SCRIPT not found, please create it..."
        exit 1
    fi
done

echo "🎉 All scripts executed!"

