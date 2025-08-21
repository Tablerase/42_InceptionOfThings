#!/usr/bin/bash
SERVER_HOST="${K3S_SERVER_HOST:-192.168.56.110}"
SERVER_PORT="${K3S_SERVER_PORT:-6443}"

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

TOKEN=$(cat /vagrant/k3s.token)
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent" sh -s - \
  --token "$TOKEN" \
  --log "/vagrant/logs/k3s-agent.log" \
  --node-ip "192.168.56.111" \
  --server "https://${SERVER_HOST}:${SERVER_PORT}"

# set -euo pipefail

# Install K3S Agent
# K3S Env vars: https://docs.k3s.io/reference/env-variables
# K3S Agent: https://docs.k3s.io/cli/agent
# K3S Config: https://docs.k3s.io/installation/configuration#configuration-file

# Create a directory for the K3S configuration
# mkdir -p /etc/rancher/k3s
# cp /vagrant/k3s-agent-config.yaml /etc/rancher/k3s/config.yaml
#
# echo "Check for K3S Server ready"
# timeout=60
# waited=0
# while ! nc -z 192.168.56.110 6443 && [ $waited -lt $timeout ]; do
#   echo -ne "\rWaited for k3s server... ($waited/$timeout)"
#   sleep 5
#   waited=$((waited+5))
# done
#
# if [ $waited -ge $timeout ]; then
#   echo "Server couldnt be reached after $waited s"
#   exit 1
# fi
#
# # Install and run the agent 
# curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent" sh -

# Check k3s status
# k3s kubectl get nodes -o wide

