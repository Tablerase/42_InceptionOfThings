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
  "argocd.sh"
  "gitlab.sh"
  "gitlab_ssh.sh"
  # "gitlab_app_repo.sh" # Guide to setup app in gitlab gui, add sshkey, create repo etc...
  # app_cicd.sh # Add gitlab app to argocd cicd
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
