#!/bin/bash
set -eu

# ---------------------------------------
# Execute all config scripts
# ---------------------------------------

SCRIPTS=(
    "cluster.sh"
    "config_kubectl.sh"
    "namespaces.sh"
    "argocd_gu.sh"
    "argocd_cli.sh"
    "gitlab.sh"
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

