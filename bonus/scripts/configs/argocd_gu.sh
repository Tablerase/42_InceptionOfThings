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


# -------------------------------------------------------------------
# Access the Argo CD API Server (which serves the UI)
# ArgoCD server runs internally. Let’s expose it:
# You can connect via one of several method
# Option A: Port Forwarding (quickest for local usage)
# open your browser to: https://localhost:8080
# -------------------------------------------------------------------
echo "🚀 Port-forwarding Argo CD server to https://localhost:8080..."
kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null 2>&1 &


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
echo "You can now log in at: https://localhost:8080 with username 'admin'."
