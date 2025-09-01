#!/bin/bash
# Bash scripting cheat sheet: https://devhints.io/bash
# set -euo pipefail

# ================================ Gitlab

helm repo add gitlab https://charts.gitlab.io/
helm repo update

helm upgrade --install gitlab gitlab/gitlab \
  --namespace gitlab \
  -f ../helm-charts/gitlab-values.yaml
