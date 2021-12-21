#!/bin/bash
if [[ $(uname -a) =~ "Ubuntu" ]]; then
  wget https://raw.githubusercontent.com/rancher/k3os/master/install.sh
  chmod +x install.sh

  cat > config.yaml <<EOF
hostname: ${host_name}
k3os:
  dns_nameservers:
  - 127.0.0.53
  k3s_args:
  - agent
  modules:
  - kvm
  - nvme
  ntp_servers:
  - 0.de.pool.ntp.org
  - 1.de.pool.ntp.org
  server_url: https://${server_1_ip}:6443
  sysctls:
    kernel.kptr_restrict: "1"
    kernel.printk: 4 4 1 7
  token: "${token}"
ssh_authorized_keys:
- ${ssh_public_key}
EOF
  ./install.sh --takeover --config config.yaml --no-format /dev/sda1 ${k3os_image}
  sleep 30
  reboot
fi