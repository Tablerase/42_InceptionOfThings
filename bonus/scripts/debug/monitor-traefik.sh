#!/bin/bash

# Namespace where Traefik is installed
NAMESPACE="kube-system"

# Log file
LOGDIR="/vagrant/logs"
mkdir -p $LOGDIR
LOGFILE="traefik.log"

# Find the Traefik pod
POD=$(kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=traefik -o jsonpath='{.items[0].metadata.name}')

if [ -z "$POD" ]; then
  echo "Traefik pod not found in namespace $NAMESPACE"
  exit 1
fi

echo "Monitoring Traefik pod: $POD in namespace $NAMESPACE"
echo "Logs will be appended to $LOGFILE"

# Follow logs with timestamps and append to file
kubectl logs -n $NAMESPACE $POD --timestamps -f >> $LOGFILE
