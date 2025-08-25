#!/bin/bash
set -euo pipefail

SERVER_HOST="${K3S_SERVER_HOST:-192.168.56.110}"
SERVER_PORT="${K3S_SERVER_PORT:-6443}"

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server" sh -s - 


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
