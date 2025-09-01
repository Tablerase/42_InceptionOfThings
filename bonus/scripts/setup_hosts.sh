#!/bin/bash

# Hosts to add
HOSTS=(
  "127.0.0.1 argocd.localhost"
  "127.0.0.1 gitlab.localhost"
  "127.0.0.1 dev.localhost"
)

# Backup /etc/hosts first
sudo cp /etc/hosts /etc/hosts.bak

# Add hosts if they don't exist
for entry in "${HOSTS[@]}"; do
  host=$(echo $entry | awk '{print $2}')
  if ! grep -q "$host" /etc/hosts; then
    echo "Adding $entry to /etc/hosts"
    echo "$entry" | sudo tee -a /etc/hosts > /dev/null
  else
    echo "$host already exists in /etc/hosts"
  fi
done

