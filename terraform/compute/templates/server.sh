#!/bin/bash

if [[ "$HOSTNAME" =~ "server-1" ]]; then
    curl -sfL https://get.k3s.io | K3S_TOKEN=${token} sh -s - server --cluster-init

elif [[ "$HOSTNAME" =~ "server-2" || "$HOSTNAME" =~ "server-3"]]; then
    curl -sfL https://get.k3s.io | K3S_TOKEN=${token} sh -s - server --server https://${server_0_ip}:6443


