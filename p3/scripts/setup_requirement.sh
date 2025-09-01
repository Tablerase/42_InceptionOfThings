#!/bin/bash
# Bash scripting cheat sheet: https://devhints.io/bash
# set -euo pipefail

# ================================ Requirements

# Bash completion
if ! dpkg -s bash-completion >/dev/null 2>&1; then
  echo "Installing bash-completion"
  sudo apt-get update
  sudo apt-get install -y bash-completion
  # Source it for current shell
  if [ -f /etc/bash_completion ]; then
      . /etc/bash_completion
  fi
fi

# Homebrew: https://brew.sh/
if ! command -v brew >/dev/null 2>&1 ; then
  echo "🍺 Installing Homebrew (non-interactive)"
  # Prevent prompts
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Setup brew
  echo >> /home/vagrant/.bashrc
  echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$HOME/.bashrc"
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

  # Need by brew
  sudo apt-get install -y build-essential
  brew install --quiet gcc || true 
  # TODO: make script continue here (after brew installation)
fi

# Docker: https://docs.docker.com/engine/install/ubuntu/#installation-methods
if ! command -v docker version >/dev/null 2>&1 ; then
  echo "🐋 Installing Docker"
  # Add Docker's official GPG key:
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl
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
  newgrp docker
fi

# Kubectl: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
if ! command -v kubectl >/dev/null 2>&1 ; then
  echo "☸️ Installing Kubectl" 
  brew install --quiet kubectl

  echo "⚙️ Kubectl: Setup completion and alias"
  sudo mkdir -p /etc/bash_completion.d
  kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
  sudo chmod a+r /etc/bash_completion.d/kubectl

  {
    echo ''
    echo '# kubectl alias and completion'
    echo 'alias k=kubectl'
    echo 'source /etc/bash_completion.d/kubectl'
    echo 'complete -o default -F __start_kubectl k'
  } >> ~/.bashrc

  # Load for current script session
  source ~/.bashrc || true
fi

# K3D: https://k3d.io/v5.6.3/#quick-start
if ! command -v k3d version >/dev/null 2>&1 ; then
  echo "☸️ Installing K3D"
  brew install k3d
fi

