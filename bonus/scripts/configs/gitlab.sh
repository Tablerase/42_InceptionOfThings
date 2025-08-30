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

# # pass the values directly
# # avoids cert-manager entirely and lets you access GitLab over HTTP locally.
# helm upgrade --install $REALEAS gitlab/gitlab \
#   --namespace gitlab \
#   --set global.ingress.configureCertmanager=false \
#   --set global.ingress.tls.enabled=false \
#   --set nginx-ingress.enabled=false \
#   --set gitlab.webservice.ingress.enabled=true \
#   --set gitlab.webservice.ingress.annotations."kubernetes\.io/ingress\.class"="traefik"


echo "✅ Verify pods status in gitlab namespace"
kubectl get pods -n gitlab

# echo "🚀 Port-forwarding gitlab-webserviceto https://localhost:8081..."
kubectl -n gitlab port-forward svc/$REALEAS-webservice-default 8081:8181 > /dev/null 2>&1 &

echo "🚀 applying ingress-gitlab http://localhost:8081..."
kubectl apply -f ../../config/ingress-gitlab.yaml

echo "🔑 Retrieving the initial root password for GitLab.."
echo
echo "--------------------------------"
kubectl -n gitlab get secret
echo "--------------------------------"
echo

GIT_ROOT_PASSWORD=$(kubectl -n gitlab get secret $REALEAS-gitlab-initial-root-password \
  -o jsonpath="{.data.password}" | base64 -d)

echo "✅ GitLab roo password: $GIT_ROOT_PASSWORD"
echo "You can now log in at: http://localhost:8081 with username 'root'."