#!/bin/bash
set -e

# ---------- CONFIG ----------
HOST_ALIAS="gitlab.localhost"
SSH_KEY="$HOME/.ssh/id_ed25519"
GITLAB_USER="root"
PROJECT_NAME="app"
SRC_DIR="$HOME/IoT/bonus/app_repo" # absolute folder with source files for gitlab repo
CLONE_DIR="$HOME/$PROJECT_NAME"

if [ ! -d "$SRC_DIR" ]; then
  echo "❌ Source directory $SRC_DIR does not exist"
  exit 1
fi

if ssh -o BatchMode=yes -T git@$HOST_ALIAS 2>&1 | grep -q "Host key verification failed"; then
  echo "❌ SSH to know_host failed. Use ./gitlab_ssh.sh to replace know_host with appropriate values"
  exit 1
fi

# ---------- 1. Check SSH config ----------
# Sometimes know_host pb (add gitlab to known_hosts):
if ! ssh -o BatchMode=yes -T git@$HOST_ALIAS 2>&1 | grep -q "Welcome to GitLab"; then
  echo "❌ SSH to GitLab failed. Check that  ssh key is added to GitLab."
  exit 1
fi
echo "✅ SSH to GitLab works"

# ---------- 2. Check if repo exists ----------
if ! git ls-remote git@$HOST_ALIAS:$GITLAB_USER/$PROJECT_NAME.git >/dev/null 2>&1; then
  echo "⚠️ Repository '$PROJECT_NAME' does not exist in GitLab!"
  echo "Please create it manually in GitLab and re-run this script."
  exit 1
fi
echo "✅ Repository exists"

# ---------- 3. Clone repo ----------
if [ -d "$CLONE_DIR" ]; then
  echo "ℹ️ Directory $CLONE_DIR already exists, pulling latest changes"
  cd "$CLONE_DIR"
  git pull
else
  git clone git@$HOST_ALIAS:$GITLAB_USER/$PROJECT_NAME.git "$CLONE_DIR"
  cd "$CLONE_DIR"
fi

# ---------- 4. Move source files ----------
echo "📦 Copying source files from $SRC_DIR to $CLONE_DIR"
rsync -av --exclude '.git' "$SRC_DIR"/ "$CLONE_DIR"/

# ---------- 5. Commit and push ----------
git add .
if git diff-index --quiet HEAD; then
  echo "ℹ️ No changes to commit"
else
  git commit -m "Sync source files"
  git push origin main
  echo "✅ Changes pushed to GitLab"
fi
