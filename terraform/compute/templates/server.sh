#!/bin/bash

if [[ "$HOSTNAME" =~ "server_0" ]]; then
    curl -sfL https://get.k3s.io | K3S_TOKEN=${token} sh -s - server --cluster-init

else
    curl -sfL https://get.k3s.io | K3S_TOKEN=${token} sh -s - server --server https://${server_0_ip}:6443