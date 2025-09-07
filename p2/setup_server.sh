#!/bin/bash
set -euo pipefail

# Install K3S Server
# Kubectl (auto installed by k3s install script): https://docs.k3s.io/quick-start#install-script
# K3S Env vars: https://docs.k3s.io/reference/env-variables
# K3S Server: https://docs.k3s.io/cli/server
# K3S Config: https://docs.k3s.io/installation/configuration#configuration-file

SERVER_HOST="${K3S_SERVER_HOST:-192.168.56.110}"
SERVER_PORT="${K3S_SERVER_PORT:-6443}"

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server" sh -s - \
  --write-kubeconfig-mode 644 \
  --log "/vagrant/logs/k3s-server.log" \
  --node-ip "${SERVER_HOST}"

timeout=60
interval=2
start=$SECONDS
echo "Waiting for K3S server API (${SERVER_HOST}:${SERVER_PORT})..."

while :; do
  waited=$((SECONDS - start))
  if (( waited >= timeout )); then
    echo "Timeout: API not reachable after ${timeout}s"
    exit 1
  fi

  # Get HTTP code (000 means connection failed)
  code=$(curl -sk -o /dev/null -w '%{http_code}' --max-time 2 "https://${SERVER_HOST}:${SERVER_PORT}/readyz" || echo 000)

  case "$code" in
    200)
      # Check body == ok (strip newlines/spaces)
      if curl -sk --max-time 2 "https://${SERVER_HOST}:${SERVER_PORT}/readyz" | grep -qx 'ok'; then
        echo "API ready (200 ok)."
        break
      fi
      ;;
    401|403)
      # Auth required means API is up enough for agent to join
      echo "API reachable (HTTP $code). Proceeding."
      break
      ;;
    000)
      ;;
    *)
      # Other codes => still starting
      ;;
  esac

  printf "\rWaiting... %ds/%ds (last code: %s)" "$waited" "$timeout" "$code"
  sleep "$interval"
done

timeout=60
start_time=$(date +%s)

echo "[INFO] Waiting for 'default' namespace to become available..."
until kubectl get namespace default >/dev/null 2>&1; do
  current_time=$(date +%s)
  elapsed=$((current_time - start_time))

  if [ $elapsed -ge $timeout ]; then
    echo "[ERROR] Timeout reached: 'default' namespace not found after ${timeout}s."
    exit 1
  fi

  sleep 2
done
echo "[INFO] 'default' namespace is ready."# Now apply manifests

# Deploy applications, services, and ingress
# - https://kubernetes.io/docs/tasks/manage-kubernetes-objects/declarative-config/#how-to-create-objects
kubectl apply -f /vagrant/multi_apps/app1/
kubectl apply -f /vagrant/multi_apps/app2/
kubectl apply -f /vagrant/multi_apps/app3/
kubectl apply -f /vagrant/multi_apps/ingress.yaml

# Check all info
# kubectl get all

# Check ingress status
# kubectl get ingress multi-app-ingress

# Connect to a host
# curl -i -H "Host:app1.com" $SERVER_HOST
