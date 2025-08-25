#!/usr/bin/env bash
set -eu

# Args: 1 = project folder, 2 = app name, 3 = replicas (default 1)
PROJECT="$1"
APP_NAME="$2"
REPLICAS="${3:-1}" # ${VAR:-DEFAULT}
IMAGE_NAME="$4"

DEPLOYMENT_FILE="$PROJECT/${APP_NAME}-deployment.yaml"

cat <<EOF > "$DEPLOYMENT_FILE"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${APP_NAME}
spec:
  replicas: $REPLICAS
  selector:
    matchLabels:
      app: ${APP_NAME}
  template:
    metadata:
      labels:
        app: ${APP_NAME}
    spec:
      containers:
      - name: ${APP_NAME}
        image: docker.io/library/${IMAGE_NAME}
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 8000
EOF

# cat <<EOF > "$DEPLOYMENT_FILE"
# apiVersion: apps/v1
# kind: Deployment
# metadata:
#   name: ${APP_NAME}
# spec:
#   replicas: $REPLICAS
#   selector:
#     matchLabels:
#       app: ${APP_NAME}
#   template:
#     metadata:
#       labels:
#         app: ${APP_NAME}
#     spec:
#       containers:
#       - name: ${APP_NAME}
#         image: ${IMAGE_NAME}
#         imagePullPolicy: Never
#         ports:
#         - containerPort: 8000
# EOF

echo "✅ Deployment YAML generated for $APP_NAME ($REPLICAS replicas)"
