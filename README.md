# Free K3s Cluster on the Oracle Cloud Infrastructure

The motivation of this project is to provide a K3s cluster with four nodes fully automatically, which is composed only of always free infrastructure resources. The deployment will be done Terraform and the user-data scripts which installs K3s automatically and build up the cluster.

## Architecture
The cluster infrastructure based on four nodes, one control-plane and three worker-nodes for your workload. A load balancer which is distributes the traffic to your nodes on port 80/443. The server-nodes are at the availability domain 2 (AD-2) and the agent node are created in AD-1. Preinstalled components are cert-manager and ingress-nginx(replacing traefik). The cluster could use the storage solution [Longhorn](https://longhorn.io), which will use the block storages of the OCI instances and shares the Kubernetes volumes between them. The following diagram give an overview of the infrastructure.
<p align="center">
    <img src="diagram/k3s_oci.png" />
</p>

## Prerequisites

First create an [Oracle Cloud Infrastructure account](https://signup.oraclecloud.com/)
Wait about 12-24h before your account is fully initialized
Next download [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) and [kubectl](https://kubernetes.io/docs/tasks/tools/)
Create an OCI Customer Secret Key.


## Configuration
First of all, you need to setup some environment variables which are needed by the OCI Terraform provider. The [Oracle Cloud Infrastructure documentation](https://docs.oracle.com/en-us/iaas/developer-tutorials/tutorials/tf-provider/01-summary.htm) gives a good overview of where the IDs and information are located and also explains how to set up Terraform. For state storage please refer to this guide: https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformUsingObjectStore.htm. Prereq folder should be able to setup the bucket. You only need to create the shared_credentails_file with Customer Secret Keys.
```
export compartment_id="<COMPARTMENT_ID>"
export region="<REGION_NAME>"
export tenancy_ocid="<TENANCY_OICD>"
export user_ocid="<USER_OICD>"
export fingerprint="<RSA_FINGERPRINT>"
export private_key_path="<PATH_TO_YOUR_PRIVATE_KEY>"
export ssh_authorized_keys='["<SSH_PUBLIC_KEY>"]'
export bucket="<BUCKET>"
export email_address="<EMAIL_ADDRESS>"

cat > terraform/.auto.tfvars <<EOF
compartment_id = ${compartment_id}
region = ${region}
tenancy_ocid = ${tenancy_ocid}
user_ocid = ${user_ocid}
bucket = ${bucket}
fingerprint = ${fingerprint}
ssh_authorized_keys = ${ssh_authorized_keys}
private_key_path = ${private_key_path}
email_address = ${email_address}
EOF
cp terraform/.auto.tfvars prereq/.auth.tfvars
```

## Deployment
The deployment is a straight forwards process. First, start with a Terraform prereq init:
```
cd prereq
terraform init
```
Second, you have to create a Terraform plan by this command:
```
terraform plan -out .tfplan
```
And last apply the plan:
```
terraform apply ".tfplan"
```
These commands created the OCI Bucket to store statefile for the cluster.

```
cd terraform
terraform init
terraform plan
```

After a couple minutes the OCI instances are created and the Cluster is up and running. And are able to connect via SSH to your Server-node-1 to get the kube-config.
```
export KUBECONFIG=${pwd}/k3s_fixed.yaml
```

Now you can use ```kubectl``` to manage your cluster and check the nodes:
```
kubectl get nodes
```

## Longhorn Installation
Finally, you have to deploy [Longhorn](https://longhorn.io) the distributed block storage by the following commands of the ```kubectl``` or ```helm``` method:

Method 1 by ```kubectl```:
```
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.2.3/deploy/longhorn.yaml
```

Method 2 by ```helm```:
You can find a shell script with all commands in the ```services``` folder which run all the following commands at once.
```bash
helm repo add longhorn https://charts.longhorn.io
helm repo update
kubectl create namespace longhorn-system
helm install longhorn longhorn/longhorn --namespace longhorn-system
```
Method 3 by k3s [helm-controller](https://rancher.com/docs/k3s/latest/en/helm/)
```yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: longhorn-system
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: longhorn
  namespace: longhorn-system
spec:
  repo: https://charts.longhorn.io
  chart: longhorn
  version: v1.7.1
  targetNamespace: longhorn-system
  set:
    global.systemDefaultRegistry: ""
```

Additionally, for both methods you have to remove local-path as default provisioner and set Longhorn as default:
```bash
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
kubectl patch storageclass longhorn -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

Check the Longhorn ```storageclass```:
```bash
kubectl get storageclass
```

After a some minutes all pods are in the running state and you can connect to the Longhorn UI by forwarding the port to your machine:
```bash
kubectl port-forward deployment/longhorn-ui 8000:8000 -n longhorn-system
```

Use this URL to access the interface: ```http://127.0.0.1:8000``` .

## Automatically certificate creation via Let's Encrypt
This is already preinstalled with letsencrypt-staging clusterissuer.

For propagating your services, it is strongly recommended to use SSL encryption. In this case you have to deploy certificates for all of your services which should be reachable at the internet. To fulfill this requirement you can use the [```cert-manager```](https://cert-manager.io/) deployment in the ```services\cert-manager``` folder.

First, you have to execute the ```cert-manager.sh``` or the following commands:
```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.7.1 \
  --set installCRDs=true
```
OR
```yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: cert-manager
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: cert-manager
  namespace: cert-manager
spec:
  repo: https://charts.jetstack.io
  chart: cert-manager
  version: v1.7.1
  targetNamespace: cert-manager
  set:
    global.systemDefaultRegistry: ""
  valuesContent: |-
    installCRDS: true
```

Second, add a cluster issuer by editing and deploy ```cluster_issuer.yaml```file by replacing it with your email address  and your domain:
```yaml
...
spec:
  acme:
    email: <your_email>@<your-domain>.<tld> # replace
...
```

Finally, when you deploy a service you have to add an ingress resource. You can use the example file ```ingress_example.yaml``` and edit it for your service:
```yaml
...
spec:
  rules:
  - host: <subdomain>.<your-domain>.<tld>                # replace
    http:
      paths:
      - path: /
        backend:
          serviceName: <service-name>                    # replace
          servicePort: 80
  tls:
  - hosts:
    - <subdomain>.<your-domain>.<tld>                    # replace
    secretName: <subdomain>-<your-domain>-<tld>-prod-tls # replace
...
```

If you want you could try out with this simple page which responds http200 always:
```yaml
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
          # cert-manager.io/cluster-issuer: letsencrypt-prod
        hosts:
          -  # -- Host address. Helm template can be passed.
            host: nullserv.1.1.1.1.nip.io #replace your NLB IP
            paths:
              -  # -- Path.  Helm template can be passed.
                path: /
                # -- Ignored if not kubeVersion >= 1.14-0
                pathType: Prefix
        tls:
          - hosts:
              - nullserv.1.1.1.1.nip.io #replace your NLB IP
            secretName: nullserv-tls

```

Test it out in moments with:
```bash
curl -sk https://nullserv.1.1.1.1.nip.io -w "%{http_code}"
```

The last step needs to be done for every service. In this deployment step the cert-manager will handle the communication to Let's Encrypt and add the certificate to your service ingress resource.

## Demo resources

- [system-upgrade](./demo/system-upgrade.md)
- [application](./demo/application.md)