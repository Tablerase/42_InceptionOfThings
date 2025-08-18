# InceptionOfThings

Orchestration project with Vagrant and Kubernetes 3d &amp; 3s

## Research

### K3S

- [K3S Install Config Script](https://docs.k3s.io/installation/configuration)
  - [Install Env Vars](https://docs.k3s.io/reference/env-variables)
- [📑 K3S Documentation](https://docs.k3s.io/)

K3S is a lightweight Kubernetes distribution designed for resource-constrained environments and edge computing. It simplifies the deployment and management of Kubernetes clusters by reducing the complexity and resource requirements typically associated with standard Kubernetes installations.

#### Architecture

![K3S Architecture](https://docs.k3s.io/assets/images/how-it-works-k3s-revised-9c025ef482404bca2e53a89a0ba7a3c5.svg)

### Vagrant

- [Vagrant Install](https://developer.hashicorp.com/vagrant/install)
- [📑 Vagrant Documentation](https://developer.hashicorp.com/vagrant/docs)

Vagrant is a tool for building and managing virtualized development environments. It allows developers to create reproducible and portable development environments using simple configuration files. Vagrant can work with various virtualization providers, such as VirtualBox, VMware, and cloud providers like AWS and Azure.

#### Vagrant File

When you use `vagrant up`, Vagrant looks for a file named `Vagrantfile` in the following order:

```bash
[home]/[current_user]/[parent_dir]/[current_directory]/Vagrantfile
[home]/[current_user]/[parent_dir]/Vagrantfile
[home]/[current_user]/Vagrantfile
[home]/Vagrantfile
/Vagrantfile
```

To create a vagrant file, simply create a file named `Vagrantfile` in the desired directory and define your virtual machine configuration using the Vagrant configuration syntax.

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"

  config.vm.network "forwarded_port", guest: 80, host: 8080

  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y apache2
  SHELL
end
```

#### Vagrant cmds

```bash
vagrant up
vagrant halt
vagrant destroy
```

```bash
# Remove a VM
vagrant destroy <vm_name>
# Force removal
vagrant destroy <vm_name> --force
```

### VirtualBox

[Linux Installation](https://www.virtualbox.org/wiki/Linux_Downloads)

```bash
# List of runnings VMs
VBoxManage list runningvms
```

```bash
# Kernel-based Virtual Machine: conflict resolution - unload KVM modules
sudo modprobe -r kvm_intel kvm
```
