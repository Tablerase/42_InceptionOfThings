#!/usr/bin/env bash
set -eu

INGRESS_FILE="/vagrant/projects/ingress.yaml"

cat <<EOF > "$INGRESS_FILE"
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: apps-ingress
  annotations:
    kubernetes.io/ingress.class: "traefik"
spec:
  rules:
  - host: app1.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app-one-service
            port:
              number: 80
  - host: app2.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app-two-service
            port:
              number: 80
  - host:
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app-three-service
            port:
              number: 80
EOF

echo "✅ Ingress YAML generated"
