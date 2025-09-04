#!/bin/bash
set -euo pipefail

# --------------------------------------------
# Deploying Argo CD
# This sets up all the components
# —including the API server and web UI—
# inside the argocd namespace.
# --------------------------------------------
echo "📥 Deploying Argo CD..."
# source: https://argo-cd.readthedocs.io/en/stable/
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml


# Wait for Argo CD pods to be ready
# ---------------------------------------------
echo "⏳ Waiting for Argo CD pods to be ready..."
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s

echo "✅ Verify pods status"
kubectl get pods -n argocd

# openssl req -x509 -nodes -days 365 \
#   -newkey rsa:2048 \
#   -keyout argocd.key \
#   -out argocd.crt \
#   -subj "/CN=argocd.local/O=argocd.local"

# kubectl create secret tls argocd-tls \
#   --cert=argocd.crt \
#   --key=argocd.key \
#   -n argocd

kubectl patch configmap argocd-cmd-params-cm -n argocd \
  --type merge \
  -p '{"data":{"server.insecure":"true"}}'


# # for ingress-argocd.yaml
echo "127.0.0.1 argocd.local" | sudo tee -a /etc/hosts
echo "🚀 applying ingress-argocd https://argocd.local..."
kubectl apply -f ../../config/ingress-argocd.yaml


# -------------------------------------------------------------------
# Retrieve the initial admin password & log in to the UI
# Use the username admin and that password to log in via 
# the Argo CD UI at https://localhost:8080
# -------------------------------------------------------------------
echo "🔑 Retrieving Argo CD admin password..."
echo
echo "--------------------------------"
kubectl -n argocd get secret
echo "--------------------------------"
echo

ARGOGU_ADMIN_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d)

echo "✅ Argo CD admin password: $ARGOGU_ADMIN_PASSWORD"
echo "You can now log in at: http://localhost:8080 with username 'admin'."
