#!/bin/bash
# Bash scripting cheat sheet: https://devhints.io/bash
# set -euo pipefail

# ================================ Project

# Project Cluster
CLUSTER_NAME="p3-cluster"
APP_PORT=8888
APP_NODEPORT=30080
if ! k3d cluster list | grep -q "^${CLUSTER_NAME}"; then
  echo "Creating k3d cluster ${CLUSTER_NAME}..."
  # k3d cluster create ${CLUSTER_NAME} --servers 1 --agents 0 \
    # --port "80:80@loadbalancer"
  k3d cluster create ${CLUSTER_NAME} --servers 1 --agents 0 \
    --port "$APP_PORT:$APP_NODEPORT@server:0" \
    --port "80:80@loadbalancer"
  # Merge current project config (auto created at cluster creation) with defautl config ($HOME/.kube/config)
  k3d kubeconfig merge ${CLUSTER_NAME} --kubeconfig-switch-context
else
  echo "Cluster ${CLUSTER_NAME} already exists, skipping creation."
fi

# ArgoCD: https://argo-cd.readthedocs.io/en/stable/getting_started/

NAMESPACES=("dev" "argocd")
for ns in "${NAMESPACES[@]}"; do
  if ! kubectl get ns | grep -q "$ns"; then
    echo "☸️ Creating kubernetes $ns namespaces"
    kubectl create namespace $ns
  else
    echo "☸️ $ns namespaces already exists"
  fi
done

if ! kubectl get pods --all-namespaces | grep argocd | grep -q Running; then
  echo "☸️ Installing ArgoCD into his namespace"
  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
fi

if ! command -v argocd version >/dev/null 2>&1 ; then
  echo "🦑 Installing ArgoCD CLI"
  brew install argocd
fi

# Wait for ArgoCD server pod to be Running
echo "⏳ Waiting for ArgoCD server pod..."
sleep 5
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=120s

# Allow WebUI for ArgoCD
if ! pgrep -f "kubectl port-forward.*argocd-server" >/dev/null; then
  echo "☸️ Starting ArgoCD WebUI (port-forward)"
  # Here address on 0.0.0.0 to allow host machine to reach VM argocd server: https://stackoverflow.com/questions/72946576/cant-access-argocd-ui-that-is-in-a-vm-with-port-forwarding-set-in-vagrant-file?utm_source=chatgpt.com
  # kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8080:443 &
  LOG_DIR="/tmp/logs"
  mkdir -p $LOG_DIR
  kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8080:443 > $LOG_DIR/argocd-portforward.log 2>&1 &
  sleep 5   # give it a few seconds to bind
fi

# Handle ArgoCD admin secret
if kubectl get secret argocd-initial-admin-secret -n argocd >/dev/null 2>&1; then
  echo "🔑 Retrieving ArgoCD initial admin password..."
  ARGOCD_ADMIN_PASS=$(kubectl get secret argocd-initial-admin-secret \
    -n argocd -o jsonpath="{.data.password}" | base64 -d)
  echo "$ARGOCD_ADMIN_PASS" > /home/vagrant/.argocd_admin_pass.old
  chmod 600 /home/vagrant/.argocd_admin_pass.old
  echo "✅ ArgoCD initial password stored at /home/vagrant/.argocd_admin_pass.old"

  # TODO: Make password management handled the same as bonus

  # Define new password
  NEW_PASS=${ARGOCD_NEW_PASS:-ChangeMe123!}
  echo "🔄 Updating ArgoCD admin password..."

  # Login with the initial password
  argocd login localhost:8080 \
    --username admin \
    --password "$ARGOCD_ADMIN_PASS" \
    --insecure
  # Update password
  argocd account update-password \
    --current-password "$ARGOCD_ADMIN_PASS" \
    --new-password "$NEW_PASS"
  # Save new password securely
  echo "$NEW_PASS" > /home/vagrant/.argocd_admin_pass
  chmod 600 /home/vagrant/.argocd_admin_pass

  echo "✅ New ArgoCD password set and stored at /home/vagrant/.argocd_admin_pass"
  echo "   Use it with: argocd login localhost:8080 --username admin --password \$(cat ~/.argocd_admin_pass) --insecure"
fi


