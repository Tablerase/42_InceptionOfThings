#!/bin/bash

set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <version> (allowed: 1 or 2)"
  exit 1
fi

NEW_VERSION="$1"

# Allow only 1 or 2
if [[ "$NEW_VERSION" != "1" && "$NEW_VERSION" != "2" ]]; then
  echo "❌ Invalid version: $NEW_VERSION. Only '1' or '2' are allowed."
  exit 1
fi

DEPLOY_FILE="./manifests/deployment.yaml"

# 1️⃣ Swap version in deployment.yaml
echo "🔄 Updating $DEPLOY_FILE to version v$NEW_VERSION..."
sed -i "s|\(wil42/playground:\)[^[:space:]]*|\1v$NEW_VERSION|g" "$DEPLOY_FILE"

# 2️⃣ Git add, commit, push
git add "$DEPLOY_FILE"
git commit -m "chore: update playground image to v$NEW_VERSION"
git push

echo "✅ Updated version to v$NEW_VERSION and pushed to Git."

