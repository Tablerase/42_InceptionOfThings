#!/bin/bash
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

# Save the token for agents to use
cat /var/lib/rancher/k3s/server/token > /vagrant/k3s.token

# set -euo pipefail

# Install K3S Server
# Kubectl (auto installed by k3s install script): https://docs.k3s.io/quick-start#install-script
# K3S Env vars: https://docs.k3s.io/reference/env-variables
# K3S Server: https://docs.k3s.io/cli/server
# K3S Config: https://docs.k3s.io/installation/configuration#configuration-file

# Create a directory for the K3S configuration
# mkdir -p /etc/rancher/k3s
# cp /vagrant/k3s-server-config.yaml /etc/rancher/k3s/config.yaml

# Install and run the server
# curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server" sh - 

# echo "Waiting for server node to become Ready..."
# for i in {1..60}; do
#   if k3s kubectl get nodes 2>/dev/null | grep -q 'Ready'; then
#     break
#   fi
#   sleep 2
# done
#
# Point kubectl to the k3s kubeconfig (optional if using 'k3s kubectl')
# export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# echo "Check for K3S Server ready"
# timeout=60
# waited=0
# while ! k3s kubectl get nodes --no-headers 2>/dev/null | grep -q 'Ready' && [ $waited -lt $timeout ]; do
#   echo -ne "\rWaited for k3s server... ($waited/$timeout)"
#   sleep 5
#   waited=$((waited+5))
# done
#
# if [ $waited -ge $timeout ]; then
#   echo "Server couldnt be reached after $waited s"
#   exit 1
# fi

