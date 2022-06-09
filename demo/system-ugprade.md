# This is a demo for K3s system-upgade

## Connection

```bash
export KUBECONFIG=${pwd}/terraform/k3s_fixed.yaml
```

## Install prereq

```bash
kubectl apply -f https://github.com/rancher/system-upgrade-controller/releases/download/v0.9.1/crd.yaml
kubectl apply -f https://github.com/rancher/system-upgrade-controller/releases/download/v0.9.1/system-upgrade-controller.yaml
```

## Demo

### K3s upgrade
```bash
kubectl apply -f - <<EOF
apiVersion: upgrade.cattle.io/v1
kind: Plan
metadata:
  name: k3s-server-plan
  namespace: system-upgrade
  labels:
    k3s-upgrade: server
spec:
  concurrency: 1
  cordon: true
  drain:
    force: true
  nodeSelector:
    matchExpressions:
    - key: node-role.kubernetes.io/control-plane
      operator: Exists
    - key: k3s-upgrade
      operator: Exists
    - key: k3s-upgrade
      operator: NotIn
      values:
        - "disabled"
        - "false"
  serviceAccountName: system-upgrade
  tolerations:
  - operator: Exists
  upgrade:
    image: rancher/k3s-upgrade
  version: v1.22.9+k3s1
EOF
```

```bash
kubectl apply -f - <<EOF
apiVersion: upgrade.cattle.io/v1
kind: Plan
metadata:
  name: k3s-worker-plan
  namespace: system-upgrade
  labels:
    k3s-upgrade: worker
spec:
  concurrency: 1
  cordon: true
  nodeSelector:
    matchExpressions:
    - key: node-role.kubernetes.io/master
      operator: DoesNotExist
    - key: node-role.kubernetes.io/control-plane
      operator: DoesNotExist
    - key: k3s-upgrade
      operator: Exists
    - key: k3s-upgrade
      operator: NotIn
      values:
        - "disabled"
        - "false"
  prepare:
    args:
    - prepare
    - k3s-master-plan
    image: rancher/k3s-upgrade
  serviceAccountName: system-upgrade
  tolerations:
  - operator: Exists
  upgrade:
    image: rancher/k3s-upgrade
  version: v1.22.9+k3s1
EOF
```

```bash
kubectl label nodes k3s-upgrade=true
```



### Update the OS itself

This is the script which will execute the upgrade process

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: focal
  namespace: system-upgrade
type: Opaque
stringData:
  upgrade.sh: |-
    #!/bin/sh
    set -e
    apt-get --assume-yes update
    apt-get --assume-yes upgrade
    if [ -f /run/reboot-required ]; then
      cat /run/reboot-required
      reboot
    fi
```

First we label all nodes to be capable of os-upgrade

```bash
kubectl label node --all os-upgrade=true
```

One node will be excluded:

```bash
kubectl label node k3s-worker-3 --overwrite os-upgrade=false
```

```bash
kubectl apply -f - <<EOF
apiVersion: upgrade.cattle.io/v1
kind: Plan
metadata:
  name: focal
  namespace: system-upgrade
spec:
  concurrency: 1
  drain:
    force: true
  nodeSelector:
    matchExpressions:
    - key: os-upgrade
      operator: Exists
    - key: os-upgrade
      operator: NotIn
      values:
        - "disabled"
        - "false"
    - key: plan.upgrade.cattle.io/focal
      operator: Exists
  secrets:
  - name: impish
    path: /host/run/system-upgrade/secrets/focal
  serviceAccountName: system-upgrade
  upgrade:
    args:
    - sh
    - /run/system-upgrade/secrets/focal/upgrade.sh
    command:
    - chroot
    - /host
    image: ubuntu
  version: focal
EOF
```

Then we could create a cronjob for the upgrade to start on every Saturday at 04:05.

```bash
kubectl apply -f - <<EOF
apiVersion: batch/v1
kind: CronJob
metadata:
  name: focal-auto-update
  namespace: system-upgrade
spec:
  concurrencyPolicy: Allow
  failedJobsHistoryLimit: 1
  jobTemplate:
    metadata:
      creationTimestamp: null
      name: focal-auto-update
    spec:
      template:
        metadata:
          creationTimestamp: null
        spec:
          containers:
          - command:
            - kubectl
            - label
            - nodes
            - --all
            - --overwrite
            - plan.upgrade.cattle.io/focal=true
            image: rancher/kubectl:v1.22.6
            imagePullPolicy: IfNotPresent
            name: auto-update
            resources: {}
            terminationMessagePath: /dev/termination-log
            terminationMessagePolicy: File
          dnsPolicy: ClusterFirst
          restartPolicy: OnFailure
          schedulerName: default-scheduler
          serviceAccountName: system-upgrade
          securityContext: {}
          terminationGracePeriodSeconds: 30
  schedule: 5 4 * * 6
  successfulJobsHistoryLimit: 3
  suspend: false
EOF
```