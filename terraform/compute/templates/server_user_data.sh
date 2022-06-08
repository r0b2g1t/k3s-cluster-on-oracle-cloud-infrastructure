#!/bin/bash

if [[ $(uname -a) =~ "Ubuntu" ]]; then
  iptables -F
  netfilter-persistent save
  mkdir -p /etc/rancher/k3s
  mkdir -p /var/lib/rancher/k3s/server/manifests
  if [[ "$HOSTNAME" =~ "k3s-server-1" ]]; then

      cat > /etc/rancher/k3s/config.yaml <<EOF
write-kubeconfig-mode: "0644"
token: "${token}"
disable:
  - traefik
  - servicelb
tls-san:
  - "api.${nlb_public_ip}.nip.io"
  - "api.${nlb_private_ip}.nip.io"
EOF
  elif [[ "$HOSTNAME" =~ "k3s-server-2" ]]; then
      cat > /etc/rancher/k3s/config.yaml <<EOF
write-kubeconfig-mode: "0644"
token: "${token}"
server: https://${nlb_private_ip}:6443
disable:
  - traefik
  - servicelb
tls-san:
  - "api.${nlb_public_ip}.nip.io"
  - "api.${nlb_private_ip}.nip.io"

EOF
  fi;

  curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server" INSTALL_K3S_VERSION=${k3s_version} sh -
fi
cat > /var/lib/rancher/k3s/server/manifests/00-nullserv-helmchart.yaml <<EOF
---
apiVersion: v1
kind: Namespace
metadata:
  name: ingress-nginx
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: ingress-nginx
  namespace: ingress-nginx
spec:
  repo: https://kubernetes.github.io/ingress-nginx
  chart: ingress-nginx
  set:
    global.systemDefaultRegistry: ""
  valuesContent: |-
    controller:
      ingressClassResource:
        default: true
      hostNetwork: true
EOF
cat > /var/lib/rancher/k3s/server/manifests/01-cert-manager-helmchart.yaml <<EOF
---
apiVersion: v1
kind: Namespace
metadata:
  name: cert-maanger
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: cert-manager
  namespace: cert-manager
spec:
  repo: https://charts.jetstack.io
  chart: cert-manager
  version: v1.7.2
  set:
    global.systemDefaultRegistry: ""
  valuesContent: |-
    installCRDs: true
EOF
cat > /var/lib/rancher/k3s/server/manifests/02-cert-manager-issuer.yaml <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    # You must replace this email address with your own.
    # Let's Encrypt will use this to contact you about expiring
    # certificates, and issues related to your account.
    email: ${email_address}
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      # Secret resource that will be used to store the account's private key.
      name: letsencrypt-staging-key
    # Add a single challenge solver, HTTP01 using nginx
    solvers:
    - http01:
        ingress:
          class: nginx
EOF
cat > /var/lib/rancher/k3s/server/manifests/03-nullserv-helmchart.yaml <<EOF
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: nullserv
  namespace: default
spec:
  repo: https://k8s-at-home.com/charts/
  chart: nullserv
  set:
    global.systemDefaultRegistry: ""
  valuesContent: |-
    ingress:
      main:
        # -- Enables or disables the ingress
        enabled: true
        ingressClassName: "nginx"
        annotations:
          cert-manager.io/cluster-issuer: letsencrypt-staging
        hosts:
          - host: nullserv.${nlb_public_ip}.nip.io
            paths:
              -  # -- Path.  Helm template can be passed.
                path: /
                # -- Ignored if not kubeVersion >= 1.14-0
                pathType: Prefix
        tls:
          - hosts:
              - nullserv.${nlb_public_ip}.nip.io
            secretName: nullserv-tls
EOF