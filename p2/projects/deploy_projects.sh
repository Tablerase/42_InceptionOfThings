#!/bin/bash

# deployment automation script for a local Kubernetes setup
set -eu

PROJECTS_DIR="/vagrant/projects"

# ----------------------------
# 1️⃣ Deploy apps
# ----------------------------
for PROJECT in "$PROJECTS_DIR"/*; do
  if [ -d "$PROJECT" ]; then
    FOLDER_NAME=$(basename "$PROJECT")
    
    case "$FOLDER_NAME" in
      app1) APP_NAME="app-one" ;;
      app2) APP_NAME="app-two" ;;
      app3) APP_NAME="app-three" ;;
      *) APP_NAME="$FOLDER_NAME" ;; # fallback
    esac

    IMAGE_NAME="${APP_NAME}:latest"
    TAR_FILE="${APP_NAME}.tar"

    echo "🚀 Deploying $APP_NAME"

    cd "$PROJECT"

    # Build and import Docker image
    docker build -t $IMAGE_NAME .
    docker save $IMAGE_NAME -o $TAR_FILE
    sudo k3s ctr image import $TAR_FILE
    rm -f $TAR_FILE

    # Set replicas: app2=3, others=1
    REPLICAS=1
    if [[ "$FOLDER_NAME" == "app2" ]]; then
      REPLICAS=3
    fi

    bash $PROJECTS_DIR/generate_deployment_yaml.sh "$PROJECT" "$APP_NAME" "$REPLICAS" "$IMAGE_NAME"
    bash $PROJECTS_DIR/generate_service_yaml.sh "$PROJECT" "$APP_NAME"

    # Apply manifests
    sudo k3s kubectl apply --validate=false -f "$PROJECT/${APP_NAME}-deployment.yaml"
    sudo k3s kubectl apply --validate=false -f "$PROJECT/${APP_NAME}-service.yaml"
  fi
done

# ----------------------------
# 2️⃣ Generate and apply Ingress for apps
# ----------------------------
bash $PROJECTS_DIR/generate_ingress_yaml.sh
sudo k3s kubectl apply --validate=false -f $PROJECTS_DIR/ingress.yaml

echo "✅ All apps deployed with ingress"



# ----------------------------
# 3️⃣ Install Kubernetes Dashboard (v2.7.0 manifest)
# ----------------------------
echo "🚀 Installing Kubernetes Dashboard..."
sudo k3s kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

# ----------------------------
# 4️⃣ Wait for Dashboard pods to be ready
# ----------------------------
echo "⏳ Waiting for Kubernetes Dashboard pods to be ready..."
until sudo k3s kubectl -n kubernetes-dashboard get pods \
      -l k8s-app=kubernetes-dashboard \
      -o jsonpath='{.items[0].status.containerStatuses[0].ready}' | grep -q "true"; do
    sleep 5
    echo "Waiting..."
done
echo "✅ Dashboard pods are ready"

# ----------------------------
# 5️⃣ Apply RBAC for admin user
# ----------------------------
echo "🚀 Creating Dashboard ServiceAccount and ClusterRoleBinding..."
sudo k3s kubectl apply -f /vagrant/dashboard/dashboard-serviceaccount.yaml
sudo k3s kubectl apply -f /vagrant/dashboard/dashboard-clusterrolebinding.yaml

# ----------------------------
# 6️⃣ Print Dashboard token
# ----------------------------
echo "🔑 Dashboard token (use this to log in):"
sudo k3s kubectl -n kubernetes-dashboard create token admin-user
