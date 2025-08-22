#!/bin/bash
# (Optional - for local dns in browser with domain: app1.com, app2.com)

HOST="192.168.56.110"
APP1=("$HOST" "app1.com")
APP2=("$HOST" "app2.com")

# Define Local DNS
add_host() {
  local IP=$1
  local HOSTNAME=$2
  local FILE="/etc/hosts"

  if [ -z "$IP" ] || [ -z "$HOSTNAME" ]; then
      echo "Add Host Usage: add_host <ip> <hostname>"
      return 1
  fi

  # Check if entry already exists
  if grep -q "$HOSTNAME" "$FILE"; then
      echo "❌ $HOSTNAME already exists in $FILE"
  else
      echo "➕ Adding $IP $HOSTNAME"
      echo "$IP    $HOSTNAME" | sudo tee -a "$FILE" > /dev/null
      echo "✅ Done"
  fi
}

for APP in APP1 APP2; do
  arr=("${!APP}")
  add_host "${arr[0]}" "${arr[1]}"
done


