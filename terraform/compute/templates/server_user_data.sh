#!/bin/bash

if [[ $(uname -a) =~ "Ubuntu" ]]; then
  wget https://raw.githubusercontent.com/rancher/k3os/master/install.sh
  chmod +x install.sh

  if [[ "$HOSTNAME" =~ "server-1" ]]; then
      cat > config.yaml <<EOF
hostname: ${host_name}
k3os:
  dns_nameservers:
  - 127.0.0.53
  k3s_args:
  - server
  - --cluster-init       # <-- When running a multi server cluster (only add this to the first node of the cluster!)
  - --node-ip=${server_1_ip} # <-- Private network IP of this machine
  modules:
  - kvm
  - nvme
  ntp_servers:
  - 0.de.pool.ntp.org
  - 1.de.pool.ntp.org
  sysctls:
    kernel.kptr_restrict: "1"
    kernel.printk: 4 4 1 7
  token: "${token}"
ssh_authorized_keys:
- ${ssh_public_key}
EOF
  elif [[ "$HOSTNAME" =~ "server-2" ]]; then
      cat > config.yaml <<EOF
hostname: ${host_name}
k3os:
  dns_nameservers:
  - 127.0.0.53
  k3s_args:
  - server
  - --server
  - https://${server_1_ip}:6443
  modules:
  - kvm
  - nvme
  ntp_servers:
  - 0.de.pool.ntp.org
  - 1.de.pool.ntp.org
  sysctls:
    kernel.kptr_restrict: "1"
    kernel.printk: 4 4 1 7
  token: "${token}"
ssh_authorized_keys:
- ${ssh_public_key}
EOF
    sleep 30
  fi;
  ./install.sh --takeover --config config.yaml --no-format /dev/sda1 ${k3os_image}
  reboot
fi