# ================================ App Setup/Sync

# Set current namespace to argocd
kubectl config set-context --current --namespace=argocd

# REPO_URL="http://gitlab.localhost/root/repo.git"
REPO_URL="http://gitlab-webservice-default.gitlab.svc.cluster.local:8181/root/repo.git" # Because k3d kubernetes doesnt have the host dns address
APP_NS="dev"
APP_NAME="wil-playground"
APP_SVC="wil-playground-service"
APP_PORT=8888

# Create the app
# Doc: https://argo-cd.readthedocs.io/en/stable/getting_started/#creating-apps-via-cli
# App repo: https://github.com/Tablerase/42_InceptionOfThings-rcutte_manifest#
argocd app create $APP_NAME --repo $REPO_URL --path manifests --dest-server https://kubernetes.default.svc --dest-namespace dev --sync-policy automated --auto-prune --self-heal

# App status
argocd app get $APP_NAME

# Sync (OutOfSync at after init - not deployed)
# Retrieves manifests from repo and perform kubectl apply of the manifests
argocd app sync $APP_NAME

# ================================ App Port-Forward

# LOG_DIR="/vagrant/logs"
# mkdir -p "$LOG_DIR"

# Check if port-forward is already running
# if ! pgrep -f "kubectl port-forward.*$APP_SVC" >/dev/null; then
#   echo "☸️ Starting port-forward for $APP_SVC on localhost:$APP_PORT..."
#   kubectl port-forward --address 0.0.0.0 svc/$APP_SVC -n $APP_NS $APP_PORT:$APP_PORT > $LOG_DIR/$APP_SVC-portforward.log 2>&1 &
#   sleep 10  # give it a few seconds to bind
# fi
#
# # Verify
# if ss -tnl | grep -q ":$APP_PORT"; then
#   echo "✅ $APP_SVC is now reachable on localhost:$APP_PORT"
# else
#   echo "⚠️ Failed to bind port $APP_PORT"
# fi
