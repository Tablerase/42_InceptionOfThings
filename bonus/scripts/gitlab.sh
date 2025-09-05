#!/bin/bash
set -euo pipefail

# -----------------------------
# GitLab Helm Deployment Script
# -----------------------------

NAMESPACE="gitlab"
CHART="gitlab/gitlab"
VALUES="../helm-charts/gitlab-values.yaml"
# INGRESS_MANIFESTS="../manifests/ingress-gitlab.yaml"
# PORT_FORWARD_LOG="/vagrant/logs/gitlab-portforward.log"
# WEBUI_PORT_HOST=8181   # host port to access GitLab WebUI
# WEBUI_PORT_CLUSTER=8181  # service port in cluster

# -----------------------------
# Add Helm repo & update
# -----------------------------
echo "⏳ Adding/updating GitLab Helm repo..."
helm repo add gitlab https://charts.gitlab.io/ || true
helm repo update

# -----------------------------
# Install or upgrade GitLab
# -----------------------------
echo "⏳ Installing/upgrading GitLab..."
helm upgrade --install gitlab $CHART \
  -n $NAMESPACE --create-namespace \
  -f $VALUES

# -----------------------------
# Wait for GitLab webservice pod
# -----------------------------
echo "⏳ Waiting for GitLab webservice pod to be ready..."
sleep 5
kubectl wait --for=condition=Ready pod -l app=webservice,release=gitlab -n $NAMESPACE --timeout=480s

# Apply custom GitLab ingress
# echo "☸️ Applying GitLab ingress..."
# kubectl apply -f $INGRESS_MANIFESTS -n $NAMESPACE 

# -----------------------------
# Retrieve GitLab root password
# -----------------------------
echo "🔑 Retrieving GitLab root password..."
GITLAB_ROOT_PASSWORD=$(kubectl get secret gitlab-gitlab-initial-root-password -n $NAMESPACE \
  -o jsonpath='{.data.password}' | base64 --decode)

# Store password securely
mkdir -p ~/.credentials
echo "$GITLAB_ROOT_PASSWORD" > ~/.credentials/gitlab_root_password
chmod 600 ~/.credentials/gitlab_root_password
echo "✅ GitLab root password stored in ~/.credentials/gitlab_root_password"

# -----------------------------
# Start WebUI port-forward if not running
# -----------------------------
# if ! pgrep -f "kubectl port-forward.*gitlab-webservice-default" >/dev/null; then
#   echo "☸️ Starting GitLab WebUI port-forward (host $WEBUI_PORT_HOST -> cluster $WEBUI_PORT_CLUSTER)..."
#   mkdir -p /vagrant/logs
#   kubectl port-forward --address 0.0.0.0 svc/gitlab-webservice-default -n $NAMESPACE $WEBUI_PORT_HOST:$WEBUI_PORT_CLUSTER \
#     > "$PORT_FORWARD_LOG" 2>&1 &
#   sleep 5
#   echo "✅ Port-forward started. Logs: $PORT_FORWARD_LOG"
# fi

# -----------------------------
# Display access info (dev)
# -----------------------------
echo "------------------------------------"
echo "GitLab is ready!"
echo "Web UI: http://gitlab.localhost"
echo "Username: root"
echo "Password: $GITLAB_ROOT_PASSWORD"
echo "------------------------------------"

