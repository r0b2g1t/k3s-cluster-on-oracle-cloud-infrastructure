#!/bin/bash
rm -rf /etc/resolv.conf
cat > /etc/resolv.conf <<EOF
nameserver 1.1.1.2
nameserver 1.0.0.2
EOF
systemctl disable --now systemd-resolved

if [[ $(uname -a) =~ "Ubuntu" ]]; then
  iptables -F
  netfilter-persistent save
  mkdir -p /etc/rancher/k3s
  cat > /etc/rancher/k3s/config.yaml <<EOF
token: "${token}"
server: https://api.${nlb_private_ip}.nip.io:6443
EOF
  fi;
  curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent" INSTALL_K3S_VERSION=${k3s_version} sh -