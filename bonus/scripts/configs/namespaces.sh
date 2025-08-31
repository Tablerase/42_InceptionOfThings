#!/bin/bash
set -euo pipefail

# -------------------------------
# Create namespaces
# -------------------------------
echo "📂 Creating namespaces..."

kubectl create namespace dev 2>/dev/null || echo "Namespace dev already exists."
kubectl create namespace argocd 2>/dev/null || echo "Namespace argocd already exists."
kubectl create namespace gitlab 2>/dev/null || echo "Namespace gitlab already exists."
