#!/bin/bash
# hosts.sh - Add GitLab, ArgoCD, and app entries to /etc/hosts

# IP of your VM / k3d load balancer (usually 127.0.0.1 if port-forwarded,
# or the VM private IP if using Vagrant)
VM_IP="127.0.0.1"

HOSTS=(
  "gitlab.localhost"
  "argocd.localhost"
  "dev.localhost"
)

# Backup /etc/hosts before modifying
sudo cp /etc/hosts /etc/hosts.bak

for HOST in "${HOSTS[@]}"; do
  if grep -q "$HOST" /etc/hosts; then
    echo "[SKIP] $HOST already in /etc/hosts"
  else
    echo "[ADD]  $HOST → $VM_IP"
    echo "$VM_IP    $HOST" | sudo tee -a /etc/hosts >/dev/null
  fi
done

echo "✅ Hosts setup complete. You can now access:"
for HOST in "${HOSTS[@]}"; do
  echo "   http://$HOST"
done
