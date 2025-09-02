#!/bin/bash

helm repo add gitlab https://charts.gitlab.io/
helm repo update

helm upgrade --install gitlab gitlab/gitlab \
  -n gitlab --create-namespace \
  -f ../helm-charts/gitlab-values.yaml

# Wait for GitLab webservice pod to be Running
echo "⏳ Waiting for GitLab webservice pod..."
kubectl wait --for=condition=Ready pod -l app=webservice,release=gitlab -n gitlab --timeout=300s

# Allow WebUI for GitLab
if ! pgrep -f "kubectl port-forward.*gitlab-webservice-default" >/dev/null; then
  echo "☸️ Starting GitLab WebUI (port-forward)"
  mkdir -p /vagrant/logs
  # Forward GitLab 8080 -> host 8090, to avoid conflict with ArgoCD
  kubectl port-forward --address 0.0.0.0 svc/gitlab-webservice-default -n gitlab 8090:8080 \
    > /vagrant/logs/gitlab-portforward.log 2>&1 &
  sleep 5   # give it a few seconds to bind
fi
