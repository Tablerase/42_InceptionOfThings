# ================================ App Setup/Sync

# Set current namespace to argocd
kubectl config set-context --current --namespace=argocd

# Create the app
# Doc: https://argo-cd.readthedocs.io/en/stable/getting_started/#creating-apps-via-cli
# App repo: https://github.com/Tablerase/42_InceptionOfThings-rcutte_manifest#
argocd app create wil-playground --repo https://github.com/Tablerase/42_InceptionOfThings-rcutte_manifest.git --path manifests --dest-server https://kubernetes.default.svc --dest-namespace dev --sync-policy automated --auto-prune --self-heal

# App status
argocd app get wil-playground

# Sync (OutOfSync at after init - not deployed)
# Retrieves manifests from repo and perform kubectl apply of the manifests
argocd app sync wil-playground 

# ================================ App Port-Forward
APP_NS="dev"
APP_SVC="wil-playground-service"
APP_PORT=8888
APP_NODEPORT=30080
LOG_DIR="/tmp/logs"
mkdir -p "$LOG_DIR"

# Check if port-forward is already running
if ! pgrep -f "kubectl port-forward.*$APP_SVC" >/dev/null; then
  sleep 5
  echo "☸️ Starting port-forward for $APP_SVC on localhost:$APP_PORT..."
  kubectl port-forward --address 0.0.0.0 svc/$APP_SVC -n $APP_NS $APP_PORT:$APP_NODEPORT > $LOG_DIR/$APP_SVC-portforward.log 2>&1 &
  sleep 5  # give it a few seconds to bind
fi

# Verify
if ss -tnl | grep -q ":$APP_PORT"; then
  echo "✅ $APP_SVC is now reachable on localhost:$APP_PORT"
else
  echo "⚠️ Failed to bind port $APP_PORT"
fi
