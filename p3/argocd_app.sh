# Set current namespace to argocd
kubectl config set-context --current --namespace=argocd

# Create the app
# Doc: https://argo-cd.readthedocs.io/en/stable/getting_started/#creating-apps-via-cli
# App repo: https://github.com/Romina-M-A/rmohamma_42_iot_app/tree/main#
argocd app create wil-playground --repo https://github.com/Romina-M-A/rmohamma_42_iot_app.git --path . --dest-server https://kubernetes.default.svc --dest-namespace dev

# App status
argocd app get wil-playground

# Sync (OutOfSync at after init - not deployed)
# Retrieves manifests from repo and perform kubectl apply of the manifests
argocd app sync wil-playground 
