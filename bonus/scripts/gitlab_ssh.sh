#!/bin/bash
set -e

# Config
SSH_CONFIG="$HOME/.ssh/config"
SSH_KEY="$HOME/.ssh/id_ed25519"
HOST_ALIAS="gitlab.localhost"
HOSTNAME="gitlab.localhost"
PORT="32222" # use NodePort (or 2222 if port-forwarding)

# # Port Forwarding option
# kubectl port-forward -n gitlab svc/gitlab-gitlab-shell 2222:22 &
# echo $! > /tmp/gitlab-shell-portforward.pid
# echo "✅ GitLab shell forwarding started on localhost:2222"

mkdir -p ~/.ssh

# Generate key if it doesn't exist
if [ ! -f "$SSH_KEY" ]; then
  echo "🔑 No SSH key found at $SSH_KEY, generating one..."
  ssh-keygen -t ed25519 -f "$SSH_KEY" -N ""
fi

# Ensure config entry exists
if grep -q "Host $HOST_ALIAS" "$SSH_CONFIG" 2>/dev/null; then
  echo "✏️ Updating SSH config for $HOST_ALIAS"
  # Delete old entry
  sed -i "/Host $HOST_ALIAS/,+5d" "$SSH_CONFIG"
fi

cat >> "$SSH_CONFIG" <<EOF
Host $HOST_ALIAS
  HostName $HOSTNAME
  Port $PORT
  User git
  IdentityFile $SSH_KEY
  IdentitiesOnly yes
EOF

chmod 600 "$SSH_CONFIG"

if ssh -o BatchMode=yes -T git@$HOST_ALIAS 2>&1 | grep -q "Host key verification failed"; then
  echo "✅ SSH config for known hosts update"
  ssh-keygen -f "$HOME/.ssh/known_hosts" -R "[gitlab.localhost]:32222"
  ssh-keyscan -p 32222 gitlab.localhost >> "$HOME/.ssh/known_hosts"
fi

echo "✅ SSH config for $HOST_ALIAS set up"
echo "👉 Now add the following public key to GitLab:"
echo
cat "$SSH_KEY.pub"

