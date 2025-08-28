#!/bin/bash
set -euo pipefail

ARGOCD_SERVER=localhost:8080
ARGOCD_USER=admin
ARGOCD_PASS=72100830
# ARGOCD_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# Login
argocd login $ARGOCD_SERVER --username $ARGOCD_USER --password $ARGOCD_PASS --insecure

# Create app
argocd app create wil-playground \
  --repo https://github.com/Romina-M-A/rmohamma_42_iot_app \
  --path . \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace dev \
  --sync-policy automated \
  --auto-prune \
  --self-heal

# # force the first sync immediately
# argocd app sync wil-playground
