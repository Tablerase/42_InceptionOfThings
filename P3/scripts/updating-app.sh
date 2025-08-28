#!/bin/bash
set -e

NEW_VERSION=$1
if [ -z "$NEW_VERSION" ]; then
  echo "Usage: ./update.sh <new_version>"
  exit 1
fi

sed -i "s|wil42/playground:.*|wil42/playground:$NEW_VERSION|g" ../manifests/deployment.yaml
cd ../manifests
git add .
git commit -m "update to $NEW_VERSION"
git remote set-url origin git@github.com:Romina-M-A/rmohamma_42_iot_app.git
git push
