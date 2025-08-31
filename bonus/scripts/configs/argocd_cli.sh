#!/bin/bash
set -euo pipefail

# ------------------------------------------------
# Install and use the Argo CD CLI
# ------------------------------------------------
echo "📦 Installing Argo CD CLI!"
# source: https://github.com/argoproj/argo-cd/releases/tag/v3.0.13
curl -sSL -o argocd \
  https://github.com/argoproj/argo-cd/releases/download/v3.0.13/argocd-linux-amd64
sudo install -m 555 argocd /usr/local/bin/argocd

echo "🔑 temporary admin password!"
echo
echo "--------------------------------"
kubectl -n argocd get secret
echo "--------------------------------"
echo
# a built-in CLI shortcut in argocd for retriveing pass
ARGOCLI_ADMIN_PASSWORD=$(argocd admin initial-password -n argocd)

echo "✅ Argo CD CLI password: $ARGOCLI_ADMIN_PASSWORD"
echo "You can now intract with argocd"
echo "🔑 argocd login localhost:8080 --username admin --password <password> --insecure "
echo "⚠️ after loging change password with: argocd account update-password"
echo "🌐 you can reach to app: curl http://wil.local/"
echo "🚪 argocd logout localhost:8080"

# echo "🚀 Temporary kubectl port-forward..."
# kubectl port-forward svc/wil-playground-service -n dev 8888:9999 > /dev/null 2>&1 &

echo "🎉 Requirements Installation Complete!"
