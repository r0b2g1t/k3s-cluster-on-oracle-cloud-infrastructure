#!/bin/bash
apt update -y
apt upgrade -y
apt install vim

rm -rf /etc/resolv.conf
cat > /etc/resolv.conf <<EOF
nameserver 1.1.1.2
nameserver 1.0.0.2
EOF

systemctl disable --now systemd-resolved

cat >> /etc/hosts <<EOF
10.0.0.20 k3s-server-1
10.0.0.22 k3s-worker-1
10.0.0.23 k3s-worker-2
EOF

if [[ $(uname -a) =~ "Ubuntu" ]]; then
  iptables -F
  netfilter-persistent save
fi;

mkdir -p /etc/rancher/k3s


cat > /etc/rancher/k3s/config.yaml <<EOF
token: "${token}"
server: https://10.0.0.20:6443
EOF

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent" INSTALL_K3S_VERSION=${k3s_version} sh -