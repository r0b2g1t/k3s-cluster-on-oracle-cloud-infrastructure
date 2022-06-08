#!/bin/bash
if [[ $(uname -a) =~ "Ubuntu" ]]; then
  iptables -F
  netfilter-persistent save
  mkdir -p /etc/rancher/k3s
  cat > /etc/rancher/k3s/config.yaml <<EOF
token: "${token}"
server: https://${nlb_private_ip}:6443
EOF
  fi;
  curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent" INSTALL_K3S_VERSION=${k3s_version} sh -