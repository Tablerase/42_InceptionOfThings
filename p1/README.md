# P1 - Setup K3S Server and Agent

```bash
# Check ip address
ip addr show
## Only show eth1
ip addr show eth1
```

```mermaid
---
title: K3S Server - Agent Setup
config:
  layout: dagre
---
flowchart TD
  subgraph HostMachine["🖥️️️ Host Machine"]
    subgraph Vagrant["🛠️ Vagrant"]
      direction TB
      InvFile["📄 Vagrantfile"]
      PLY["📄 Provisioning Script"]
    end

    subgraph VirtualBox["🥡 VirtualBox"]
      subgraph VMServer["🖥️ loginS <br> 192.168.56.110"]
        K3S_Server["☸️ K3S Server"]
      end
      subgraph VMWorker["🖥️ loginSW <br> 192.168.56.111"]
        K3S_Agent["☸️ K3S Agent"]
      end
    end

    Vagrant -->|Provisioning| VirtualBox
    K3S_Server <-->|Communication| K3S_Agent
  end

  classDef files fill: #fadc89ff,color: #616161ff,stroke: #b4befe
  classDef database fill: #7575bdff,color: #ffffffff,stroke: #45475a
  classDef web fill: #88e68dff,color: #575757ff,stroke: #45475a
  classDef vagrant fill: #89b4fa,color: #1e1e2e,stroke: #b4befe
  classDef kubern fill: #a6e3a17c,color: #1e1e2e,stroke: #94e2d5
  classDef vbox fill: #dff8ffff,color: #1e1e2e,stroke: #dff8ffff
  classDef web-anim stroke-dasharray: 9,5, stroke-dashoffset: 900, stroke-width: 2, stroke: #489e5dff, animation: dash 25s linear infinite;
  classDef ansible-anim stroke-dasharray: 5,5, stroke-dashoffset: 300, stroke-width: 2, stroke: #e0b25cff, animation: dash 25s linear infinite;

  class K3S_Server,K3S_Agent kubern
  class Vagrant vagrant
  class VirtualBox vbox
```

## Networking

`eth1` is the name of the second ethernet network interface. In a Vagrant/VirtualBox setup, it's often used for the private or host-only network that allows VMs to communicate with each other.

- `mtu` (Maximum Transmission Unit) is the size of the largest packet that can be sent over the network interface.
- `enp0s8` is another naming convention for network interfaces in Linux, often used in cloud environments. It serves a similar purpose as `eth1`. It means "Ethernet, PCI bus 0, slot 8".
