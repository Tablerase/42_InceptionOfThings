#!/usr/bin/env bash
set -eu

PROJECT="$1"
APP_NAME="$2"

SERVICE_FILE="$PROJECT/${APP_NAME}-service.yaml"

cat <<EOF > "$SERVICE_FILE"
apiVersion: v1
kind: Service
metadata:
  name: ${APP_NAME}-service
spec:
  selector:
    app: ${APP_NAME}
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8000
  type: ClusterIP
EOF

echo "✅ Service YAML generated for $APP_NAME"
