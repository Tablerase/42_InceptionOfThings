#!/bin/bash
set -euo pipefail

REALEAS="mygitlab"

# ------------------------------------------------
# Install GitLab via Helm
# ------------------------------------------------
# # source: https://docs.gitlab.com/charts/installation/deployment/
echo "📦 Installing GitLab via Helm!"

echo "➕ Adding GitLab Helm repo"
helm repo add gitlab https://charts.gitlab.io/

echo "🔄 Updating GitLab repo..."
helm repo update

# updates a release(mygitlab) if it already exists.
# if the release doesn’t exist yet, Helm will install it.
# gitlab/gitlab tells Helm: “Look in the gitlab repo for the gitlab chart.”
echo "⏳ Waiting for $REALEAS installation, This can take 5+ minutes."
helm upgrade --install $REALEAS gitlab/gitlab \
  --namespace gitlab \
  -f ../../config/gitlab-values.yaml

echo "127.0.0.1 gitlab.local" | sudo tee -a /etc/hosts


echo "🚀 applying ingress-gitlab http://gitlab.local..."
kubectl apply -f ../../config/ingress-gitlab.yaml

kubectl port-forward svc/mygitlab-gitlab-shell -n gitlab 2222:22 > /dev/null 2>&1

echo "🔑 Retrieving the initial root password for GitLab.."
echo
echo "--------------------------------"
kubectl -n gitlab get secret
echo "--------------------------------"
echo

GIT_ROOT_PASSWORD=$(kubectl -n gitlab get secret $REALEAS-gitlab-initial-root-password \
  -o jsonpath="{.data.password}" | base64 -d)

echo "✅ GitLab roo password: $GIT_ROOT_PASSWORD"
echo "You can now log in at: http://gitlab.local with username 'root'."

# kubectl port-forward svc/mygitlab-webservice-default -n gitlab 8080:8080
