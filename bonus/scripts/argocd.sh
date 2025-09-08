#!/bin/bash

# ArgoCD: https://argo-cd.readthedocs.io/en/stable/getting_started/

ARGOCD_HOST="argocd.localhost:8080"
INGRESS_MANIFEST="../manifests/argocd_ingress.yaml"
NAMESPACE="argocd"
CREDENTIALS_DIR="$HOME/.credentials"

if ! kubectl get pods --all-namespaces | grep $NAMESPACE | grep -q Running; then
  echo "☸️ Installing ArgoCD into his namespace"
  kubectl apply -n $NAMESPACE -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
fi

if ! command -v argocd version >/dev/null 2>&1 ; then
  echo "🦑 Installing ArgoCD CLI"
  brew install argocd
fi

# Wait for ArgoCD server pod to be Running
echo "⏳ Waiting for ArgoCD server pod..."
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=argocd-server -n $NAMESPACE --timeout=120s

# Apply ingress config
kubectl apply -n $NAMESPACE -f $INGRESS_MANIFEST

# Allow WebUI for ArgoCD
LOG_DIR="/tmp/logs"
if ! pgrep -f "kubectl port-forward.*argocd-server" >/dev/null; then
  echo "☸️ Starting ArgoCD WebUI (port-forward)"
  # Here address on 0.0.0.0 to allow host machine to reach VM argocd server: https://stackoverflow.com/questions/72946576/cant-access-argocd-ui-that-is-in-a-vm-with-port-forwarding-set-in-vagrant-file?utm_source=chatgpt.com
  # kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8080:443 &
  mkdir -p $LOG_DIR
  kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8080:443 > $LOG_DIR/argocd-portforward.log 2>&1 &
  sleep 5   # give it a few seconds to bind
fi

# Handle ArgoCD admin secret
if kubectl get secret argocd-initial-admin-secret -n argocd >/dev/null 2>&1; then
  echo "🔑 Retrieving ArgoCD initial admin password..."
  mkdir -p $CREDENTIALS_DIR
  ARGOCD_ADMIN_PASS=$(kubectl get secret argocd-initial-admin-secret \
    -n $NAMESPACE -o jsonpath="{.data.password}" | base64 -d)
  echo "$ARGOCD_ADMIN_PASS" > $CREDENTIALS_DIR/.argocd_admin_pass.old
  chmod 600 $CREDENTIALS_DIR/.argocd_admin_pass.old
  echo "✅ ArgoCD initial password stored at $CREDENTIALS_DIR/.argocd_admin_pass.old"

    # Login with the initial password
  argocd login $ARGOCD_HOST \
    --username admin \
    --password "$ARGOCD_ADMIN_PASS" \
    --insecure

  # -----------------------------
  # Display access info (dev)
  # -----------------------------
  echo "------------------------------------"
  echo "Argo is ready!"
  echo "Web UI: http://argocd.localhost"
  echo "Username: admin"
  echo "Password: $ARGOCD_ADMIN_PASS"
  echo "------------------------------------"

  # # Define new password
  # NEW_PASS=${ARGOCD_NEW_PASS:-ChangeMe123!}
  # echo "🔄 Updating ArgoCD admin password..."
  # # Update password
  # argocd account update-password \
  #   --current-password "$ARGOCD_ADMIN_PASS" \
  #   --new-password "$NEW_PASS"
  # # Save new password securely
  # echo "$NEW_PASS" > $CREDENTIALS_DIR/.argocd_admin_pass
  # chmod 600 $CREDENTIALS_DIR/.argocd_admin_pass
  #
  # echo "✅ New ArgoCD password set and stored at $CREDENTIALS_DIR/.argocd_admin_pass"
  # echo "   Use it with: argocd login $ARGOCD_HOST --username admin --password \$(cat $CREDENTIALS_DIR/.argocd_admin_pass) --insecure"
fi

