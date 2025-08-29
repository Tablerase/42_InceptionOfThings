#!/bin/bash
# Bash scripting cheat sheet: https://devhints.io/bash
set -euo pipefail

# ================================ Requirements

# Homebrew: https://brew.sh/
if ! command -v brew >/dev/null 2>&1 ; then
  echo "🍺 Installing Homebrew (non-interactive)"
  # Prevent prompts
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Setup brew
  echo >> /home/vagrant/.bashrc
  echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/vagrant/.bashrc
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Bash completion
if ! dpkg -s bash-completion >/dev/null 2>&1; then
    echo "Installing bash-completion"
    sudo apt-get update
    sudo apt-get install -y bash-completion
fi

# Source it for current shell
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# Docker: https://docs.docker.com/engine/install/ubuntu/#installation-methods
if ! command -v docker version >/dev/null 2>&1 ; then
  echo "🐋 Installing Docker"
  # Add Docker's official GPG key:
  sudo apt-get update
  sudo apt-get install ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  # Add the repository to Apt sources:
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  # Installing Docker packages:
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  # Add user to docker group
  sudo usermod -aG docker $USER
fi

# Kubectl: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
if ! command -v kubectl >/dev/null 2>&1 ; then
  echo "☸️ Installing Kubectl" 
  brew install --quiet kubectl

  echo "⚙️ Kubectl: Setup completion and alias"

  # 1️⃣ Save kubectl completion script
  kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
  sudo chmod a+r /etc/bash_completion.d/kubectl

  # 2️⃣ Append alias and enable completion for it in ~/.bashrc
  {
    echo ''
    echo '# kubectl alias and completion'
    echo 'alias k=kubectl'
    echo 'source /etc/bash_completion.d/kubectl'
    echo 'complete -o default -F __start_kubectl k'
  } >> ~/.bashrc

  # 3️⃣ Load the new settings in current shell
  source ~/.bashrc
fi

# ================================ Project

# K3D: https://k3d.io/v5.6.3/#quick-start
if ! command -v k3d version >/dev/null 2>&1 ; then
  echo "☸️ Installing K3D"
  brew install k3d
fi

# Project Cluster
CLUSTER_NAME="p3-cluster"
if ! k3d cluster list | grep -q "^${CLUSTER_NAME}"; then
  echo "Creating k3d cluster ${CLUSTER_NAME}..."
  k3d cluster create ${CLUSTER_NAME}
  # Merge current project config (auto created at cluster creation) with defautl config ($HOME/.kube/config)
  k3d kubeconfig merge ${CLUSTER_NAME} --kubeconfig-switch-context
else
  echo "Cluster ${CLUSTER_NAME} already exists, skipping creation."
fi

# ArgoCD: https://argo-cd.readthedocs.io/en/stable/getting_started/

NAMESPACES=("dev" "argocd")
for ns in "${NAMESPACES[@]}"; do
  if ! kubectl get ns | grep -q "$ns"; then
    echo "☸️ Creating kubernetes $ns namespaces"
    kubectl create namespace $ns
  else
    echo "☸️ $ns namespaces already exists"
  fi
done

if ! kubectl get pods --all-namespaces | grep argocd | grep -q Running; then
  echo "☸️ Installing ArgoCD into his namespace"
  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
fi

if ! command -v argocd version >/dev/null 2>&1 ; then
  echo "🦑 Installing ArgoCD CLI"
  brew install argocd
fi

# Handle ArgoCD admin secret
if kubectl get secret argocd-initial-admin-secret -n argocd >/dev/null 2>&1; then
  echo "🔑 Retrieving ArgoCD initial admin password..."
  ARGOCD_ADMIN_PASS=$(kubectl get secret argocd-initial-admin-secret \
    -n argocd -o jsonpath="{.data.password}" | base64 -d)
  echo "$ARGOCD_ADMIN_PASS" > /home/vagrant/.argocd_admin_pass.old
  chmod 600 /home/vagrant/.argocd_admin_pass.old
  echo "✅ ArgoCD initial password stored at /home/vagrant/.argocd_admin_pass.old"

  # Define new password
  NEW_PASS=${ARGOCD_NEW_PASS:-ChangeMe123!}
  echo "🔄 Updating ArgoCD admin password..."

  # Login with the initial password
  argocd login localhost:8080 \
    --username admin \
    --password "$ARGOCD_ADMIN_PASS" \
    --insecure
  # Update password
  argocd account update-password \
    --current-password "$ARGOCD_ADMIN_PASS" \
    --new-password "$NEW_PASS"
  # Save new password securely
  echo "$NEW_PASS" > /home/vagrant/.argocd_admin_pass
  chmod 600 /home/vagrant/.argocd_admin_pass

  echo "✅ New ArgoCD password set and stored at /home/vagrant/.argocd_admin_pass"
  echo "   Use it with: argocd login localhost:8080 --username admin --password \$(cat ~/.argocd_admin_pass) --insecure"
fi

# Allow WebUI for ArgoCD
if ! kubectl get -n argocd pods | grep argocd-server | grep -q Running; then
  echo "☸️ Activate ArgoCD WebUI (disable by default)"
  # kubectl port-forward svc/argocd-server -n argocd 8080:443 &
  # Here address on 0.0.0.0 to allow host machine to reach VM argocd server: https://stackoverflow.com/questions/72946576/cant-access-argocd-ui-that-is-in-a-vm-with-port-forwarding-set-in-vagrant-file?utm_source=chatgpt.com
  # kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8080:443 &
  mkdir -p /vagrant/logs
  kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8080:443 > /vagrant/logs/argocd-portforward.log 2>&1 &
fi

