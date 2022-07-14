# This is a demo for K3s system-upgade

## Connection

```bash
export KUBECONFIG=${pwd}/terraform/k3s_fixed.yaml
export nlb_public_ip=$(terraform output --json|jq 'with_entries(.value |= .value)|.nlb_public_ip' -r)
```

## Simple application for demonstartions

This demo installs a ghost instance from HelmChart provided by [k8s-at-home](https://k8s-at-home.com)
It will request:
- certificate from letsencrypt(staging)
- deployes a single node MariaDB
- deployes a single replica Ghost

It could use PVC for MariaDB the by default k3s comes with local-path provisioner or we could install the longhorn solution.

```bash
kubectl apply -f - <<EOF
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: ghost
  namespace: default
spec:
  repo: https://k8s-at-home.com/charts/
  chart: ghost
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
          - host: ghost.${nlb_public_ip}.nip.io
            paths:
              -  # -- Path.  Helm template can be passed.
                path: /
                # -- Ignored if not kubeVersion >= 1.14-0
                pathType: Prefix
        tls:
          - hosts:
              - ghost.${nlb_public_ip}.nip.io
            secretName: ghost-tls
    env:
      url: "https://ghost.${nlb_public_ip}.nip.io"
      database__client: mysql
      database__connection__host: ghost-mariadb
      database__connection__user: ghost
      database__connection__password: ghost
      database__connection__database: ghost
      NODE_ENV: production
    mariadb:
      enabled: true
      architecture: standalone
      auth:
        database: ghost
        username: ghost
        password: ghost
        rootPassword: ghost-rootpass
      primary:
        persistence:
          enabled: false   #this is the place to turn on the default pvc
EOF
```
