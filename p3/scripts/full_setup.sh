#!/bin/bash
set -eu

# ---------------------------------------
# Execute all config scripts
# ---------------------------------------

SCRIPTS=(
  "hosts.sh"
  "requirements.sh"
  "requirements.sh"
  "project.sh"
  "app_cicd.sh" 
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
