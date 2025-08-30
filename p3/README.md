# Part 3 - ArgoCD and K3D

```mermaid
---
title: ArgoCD GitOps Workflow
---
flowchart TD;
  subgraph k3d["Cluster (p3-cluster)"]
    subgraph nsArgo["Namespace: argocd"]
      direction LR
      argo_pods["ArgoCD Pods"]
      argo_svc["ArgoCD Service"]
    end
    subgraph nsDev["Namespace: dev"]
      direction LR
      app_deployment@{ shape: proc, label: "Deployment (wil-playground)" }
      app_svc@{ shape: proc, label: "Service (wil-playground)" }
      app_pod@{ shape: proc, label: "Pod (wil-playground)" }
    end
  end

  subgraph "External"
    subgraph git_repo["Git Repo"]
      manifestD@{shape: doc, label: "deployment.yaml"}
      manifestS@{shape: doc, label: "service.yaml"}
    end
  end

  app_deployment appdeppod@--> app_pod
  app_svc appsvcpod@--> app_pod

  git_repo gitargo@-->|"Sync<br>Watches for changes"|argo_pods
  argo_pods argodep@-->|"Applies manifests"|app_deployment
  argo_pods argosvc@-->|"Applies manifests"|app_svc

  classDef k8s fill: #326ce5,stroke: #fff,stroke-width:4px,color:#fff;
  classDef cluster fill: #fff,stroke: #bbb,stroke-width:2px,color:#326ce5;
  classDef external fill: #99dfff9f,stroke: #333,stroke-width:2px, color:#333;
  classDef kub-anim stroke-dasharray: 5,5, stroke-dashoffset: 300, stroke-width: 2, stroke: #99dfffc7, animation: dash 25s linear infinite;
  classDef git-anim stroke-dasharray: 5,5, stroke-dashoffset: 300, stroke-width: 2, stroke: #e0b25cff, animation: dash 25s linear infinite;

  class argo_pods,argo_svc,app_deployment,app_pod,app_svc k8s;
  class k3d,nsArgo,nsDev cluster;
  class git_repo external;
  class gitargo git-anim;
  class argodep,argosvc,appdeppod,appsvcpod kub-anim;
```

## Setup

```bash
# Setup
./setup_requirement.sh
# Project K3D cluster + ArgoCD namespaces
./setup_project.sh
# Setup ArgoCD App
./argocd_app.sh
# Test gitflow by updating manifests repo version
cd app_repo
./update_version.sh
```

## Usefull commands

```bash
# Get app info
argocd app get wil-playground
```

```bash
# Manual sync
argocd app sync wil-playground --prune --dry-run
```

```bash
# kubectl system info
k get all -n kube-system
# kubectl get all -n <namespace>
```

```bash
# Get cluster in config
kubectl config get-contexts -o name
```

```bash
# Set current namespaces to <ns>
kubectl config set-context --current --namespace=<ns>
```

## K3D

```bash
# Remove cluster
k3d cluster delete <cluster>
```

