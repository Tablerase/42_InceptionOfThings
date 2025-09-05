#!/bin/bash
# hosts.sh - Add App entries to /etc/hosts

VM_IP="192.168.56.110"

HOSTS=(
  "app1.com"
  "app2.com"
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
