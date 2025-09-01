#!/bin/bash
set -euo pipefail

ARGOCD_SERVER=localhost:8080
ARGOCD_USER=admin
ARGOCD_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d)
# ARGOCD_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# # to access http://wil.local
echo "127.0.0.1 wil.local" | sudo tee -a /etc/hosts

# Login
argocd login $ARGOCD_SERVER --username $ARGOCD_USER --password $ARGOCD_PASS --insecure


# Create app on argocd and send request to argocd api server 
# with --sync-policy none we can rollout to the previous version of replicaset
# address of api-server in kubernetes https://kubernetes.default.svc <service name>.<namespace>.svc
argocd app create wil-playground \
  --repo http://mygitlab-webservice-default.gitlab.svc.cluster.local:8181/root/rmohamma_42_iot_app.git \
  --path . \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace dev \
  --sync-policy none

  ## with --sync-policy automated we can not rollout to previous replicaset
  # --sync-policy automated \
  # --auto-prune  none \
  # --self-heal none


# # create app on dev env send request to kubernetes api server
argocd app sync wil-playground
