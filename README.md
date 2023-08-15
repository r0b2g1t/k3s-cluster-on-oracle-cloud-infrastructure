# Free K3s Cluster on fedora CoreOS on Oracle Cloud Infrastructure (OCI)

This project is based on the [k3s-cluster-on-oracle-cloud-infrastructure](https://github.com/r0b2g1t/k3s-cluster-on-oracle-cloud-infrastructure) project which aims to automatically deploy a K3s cluster with four nodes, that is composed of only always free infrastructure resources on Oracle Cloud Infrastructure (OCI).

Unfortunately the K3OS project that that project uses as the Operating System was deprecated in 2022. Therefore, this project aims to use Fedora CoreOS as the underlying host OS. Fedora CoreOS is also a lightweight, automatically updating and immutable OS and is therefore a greatr alternative to K3OS.

The deployment is initially done by Terraform, but unfortunately, manual work is currently required to install the Fedora CoreOS Operating System over the initial OS and then install K3s on top of that.

## Architecture
The cluster infrastructure based on four nodes, two server- and two agent-nodes for workloads. A load balancer which distributes the traffic to your nodes on port 443. The server-nodes are split between at the availability domains AD-1 and AD-2, while and the agent nodes are all created in AD-2 (this is a limitation of OCI). The cluster use the storage solution [Longhorn](https://longhorn.io), which will use the block storages of the OCI instances and shares the Kubernetes volumes between them. The following diagram give an overview of the infrastructure.
<p align="center">
    <img src="diagram/k3s_oci.png" />
</p>

Network Security Groups are used to allow external access to the cluster on ports 22 (SSH), 80 and 443 (HTTP(S)), and 6443/6444 (Kubectl).

## Configuration
First of all, you need to setup some environment variables which are needed by the OCI Terraform provider. The [Oracle Cloud Infrastructure documentation](https://docs.oracle.com/en-us/iaas/developer-tutorials/tutorials/tf-provider/01-summary.htm) gives a good overview of where the IDs and information are located and also explains how to set up Terraform.

```sh
export TF_VAR_compartment_id="<COMPARTMENT_ID>"
export TF_VAR_region="<REGION_NAME>"
export TF_VAR_tenancy_ocid="<TENANCY_OICD>"
export TF_VAR_user_ocid="<USER_OICD>"
export TF_VAR_fingerprint="<RSA_FINGERPRINT>"
export TF_VAR_private_key_path="<PATH_TO_YOUR_PRIVATE_KEY>"
export TF_VAR_ssh_authorized_keys='["<SSH_PUBLIC_KEY>"]'
```

If you are deploying to a region other than uk-london-1, then you will also need to configure the init_server_image and init_agent_image variables in the same way as those above and set them to the OCID of the [Oracle-Linux-9.0-aarch64-2022.08.17-0](https://docs.oracle.com/en-us/iaas/images/image/cab2edc5-68e2-4a00-85b3-3abd7ec738ad/) and [Oracle-Linux-9.0-2022.08.17-0](https://docs.oracle.com/en-us/iaas/images/image/ad80dd84-5042-4832-a2d4-d45d283b74fa/) images respectively for your region of choice.

## Initial Deployment
Deploying the initial infrastructure is a straight forwards process:

```sh
#  Firstly, start with a Terraform init:
terraform init

# Secondly, create a Terraform plan:
terraform plan -out .tfplan

# And finally, apply the plan:
terraform apply ".tfplan"
```

After a couple minutes, the OCI network and compute instances will have been created and be up and running. They can then be connected to via SSH to then install Fedora CoreOS, and subsequently, K3s, manually. The default username is opc.
```sh
ssh -i ~/.ssh/[YOUR_KEY_FILE] opc@[SERVER_0_PUBLIC_IP]
```

Note that it's very common to receive the error `Error: 500-InternalError, Out of host capacity` when trying to provision the two 12GB Ampere control plane nodes. This is because there is very rarely free capacity in the Oracle data centres that is available for use by free-tier customers. If you see this message, then you either have to wait and try again later, or you might want to try changing the `availability_domain` value to a different availabliity domain in `terraform/compute/main.tf` for the two control plane nodes, or reducing the amount of RAM requested towards the bottom of `terraform/compute/variables.tf`.

## Fedora CoreOS installation
TODO: Come up with a nice way to generate Fedora CoreOS Butane files via Terraform and provision the nodes more easily/automatically.

Fedora CoreOS can be installed over the top of the existing nodes we have provisioned, but it requires quite a bit of manually work. Based on [this Medium article by Terrance Siu](https://medium.com/@terrancesiu/%E5%B0%86oracle-cloud%E7%9A%84vm%E6%93%8D%E4%BD%9C%E7%B3%BB%E7%BB%9F%E6%9B%BF%E6%8D%A2%E4%B8%BAfedora-coreos-cc9861023b89) (Google Translate does a good enough job if you want to translate it), we will essentially detach the boot volume from one node, then attach it to another node and do the installation from there, before unmounting it and attaching it back to the original node.

Fedora CoreOS is installed from a [Butane file](https://docs.fedoraproject.org/en-US/fedora-coreos/producing-ign/) which contains YAML configuration for the OS. Examples to get you started are located in the fedora_coreos directory. You will at least need to add your SSH key to the top of each one and edit the placeholder variables in the K3s installation command near the bottom.

The general process looks like as follows. For simplicity, I will refer to server-0, server-1, agent-0 and agent-1 as node 1, node 2, node 3 and node 4 respectively.

1. In the OCI GUI, stop nodes 1, 2 and 3.
2. Detach the Boot Volume from each of those three nodes.
3. Attach, in order, the three boot volumes on to node 4. This is under the "Attached block volumes" section of the instance. Select `Paravirtualized` for the attachment type and `Read/Write` for the Access mode.
4. You can use `watch lsblk` on node 4 to monitor the detection of each boot volume as it is attached. They will be detected as sdb, sdc and sdd respectively.
5. Copy your Butane file for nodes 1, 2 and 3 onto node 4.
6. Install Podman with `sudo dnf install podman`
7. As per the fedora_coreos/commands.sh file, for each of the three nodes:
    1. Generate the Ignition file from the Butane file:
       
       ```sh
       podman container run --interactive \
           --rm quay.io/coreos/butane:release \
           --pretty --strict < k3s-server-0.bu > k3s-server-0.ign
       ```

    2. Wipe the file system for the corresponding volume with `sudo wipefs -a /dev/sd[abc]`.
    3. Run the appropriate command for the architecture of the new node as per the fedora_coreos/commands.sh file.

       ```sh
       sudo podman run --pull=always --privileged --rm \
           -v /dev:/dev -v /run/udev:/run/udev -v .:/data -w /data \
           quay.io/coreos/coreos-installer:release \
           install /dev/sdb --architecture aarch64 -i k3s-server-0.ign
       ```

8. Detach the three boot volumes (under "Attached block volumes").
9. Attach each boot volume (under Boot Volumes) back to its original VM instance.
10. Start nodes 1, 2 and 3 up again.
11. SSH onto each of nodes 1, 2 and 3 and check everything looks OK. The default username is `core`, unless you configured something else.
12. Repeat all the above steps to install Fedora CoreOS on node 4 from one of the other nodes (node 3 is probably the best option).

# K3s Installation
To install K3s, fist run the following command from the k3s-server-0 node. The token is the value that was previously generated by Terraform and printed out. Alternatively, you can just make up your own, as long as you use the same value for each node.

If you want to access the server from outside of the Virtual Cloud Network (VCN), then you should set the --tls-san flag for any routes you wish to use. If you don't have a domain name to use, then the public IP address of the k3s-server-0 node on its own is fine. It's a good idea to have a k3s-control-plane.example.com DNS entry that points to both the k3s-server-0 and the k3s-server-1 public IP addresses for high availability.

```sh
curl -sfL https://get.k3s.io | \
    sh -s - \
    server \
    --cluster-init \
    --node-ip 10.0.0.10 \
    --token "[RANDOM_TOKEN_GENERATED_BY_TERRAFORM]" \
    --tls-san [SERVER_0_PUBLIC_IP] \
    --tls-san k3s-server-0 \
    --tls-san k3s-server-0.example.com \
    --tls-san k3s-control-plane.example.com
```

Secondly, on the k3s-server-1 node, install another control plane K3s installation with this command:

```sh
curl -sfL https://get.k3s.io | \
    sh -s - \
    server \
    --server https://10.0.0.10:6443 \
    --token "[RANDOM_TOKEN_GENERATED_BY_TERRAFORM]" \
    --tls-san [SERVER_1_PUBLIC_IP] \
    --tls-san k3s-server-1 \
    --tls-san k3s-server-1.example.com
```

Next, on the two agent nodes, add them to the cluster as follows:

```sh
curl -sfL https://get.k3s.io | \
    sh -s - \
    agent \
    --server https://10.0.0.10:6443 \
    --token "[RANDOM_TOKEN_GENERATED_BY_TERRAFORM]"
```

Finally, if you want to be able to use Kubectl from externally, copy the config off of k3s-server-0 to `~/.kube/config`, then update the `server:` line to change the IP address from 127.0.0.1 to the public IP of either k3s-server-0 or k3s-server-1, or any DNS entry that you have created for the control plane.

```sh
scp core@<SERVER_NODE_1_PUBLIC_IP>:/etc/rancher/k3s/k3s.yaml ~/.kube/config

sed -i 's/127.0.0.1/EXTERNAL_IP_OR_DNS_ENTRY/' ~/.kube/config
```

You can now use `kubectl` on your local machine to manage your cluster and check the nodes:

```sh
kubectl get nodes
```

## Longhorn Installation
Finally, you have to deploy [Longhorn](https://longhorn.io) the distributed block storage by the following commands of the `kubectl` or `helm` method:

Method 1 by `kubectl`:
```sh
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.2.3/deploy/longhorn.yaml
```

Method 2 by `helm`:
You can find a shell script with all commands in the `services` folder which run all the following commands at once.
```sh
helm repo add longhorn https://charts.longhorn.io
helm repo update
kubectl create namespace longhorn-system
helm install longhorn longhorn/longhorn --namespace longhorn-system
```

Additionally, for both methods you have to remove local-path as default provisioner and set Longhorn as default:
```sh
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
kubectl patch storageclass longhorn -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

Check the Longhorn `storageclass`:
```sh
kubectl get storageclass
```

After a some minutes all pods are in the running state and you can connect to the Longhorn UI by forwarding the port to your machine:
```sh
kubectl port-forward deployment/longhorn-ui 8000:8000 -n longhorn-system
```

Use this URL to access the interface: `http://127.0.0.1:8000` .

## Automatically certificate creation via Let's Encrypt
For propagating your services, it is strongly recommended to use TLS encryption. In this case you have to deploy certificates for all of your services which should be reachable via the internet. To fulfill this requirement you can use the [`cert-manager`](https://cert-manager.io/) deployment in the `services/cert-manager/` directory. A more detailed explanation of how to set this up can be found on [sysadmins.co.za](https://sysadmins.co.za/https-using-letsencrypt-and-traefik-with-k3s/).

These instructions assume that you already have some service running in your cluster tyhat you wish to expose.

Firstly, you need to install cert-manager either by Helm using the `services/cert-manager/cert-manager.sh` script, or by [applying YAML files from Github](https://cert-manager.io/docs/installation/kubectl/) as follows:
```sh
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.10.1/cert-manager.yaml
```

Secondly, add a ClusterIssuer by replacing the placeholder email address in the `services/cert-manager/cluster_issuer.yaml` file with your own and the applying it into your cluster:
```sh
sed -i 's/YOUR_EMAIL_HERE/your.real.email@address.com/' services/cert-manager/cluster_issuer.yaml

k apply -f services/cert-manager/cluster_issuer.yaml
```

Finally, when you deploy a service you have to add an ingress resource. You can use the example file `services/cert-manager/ingress_example.yaml` and edit it for your service:
```sh
sed -i 's/YOUR_DOMAIN_HERE/your-real-domain.com/g' services/cert-manager/ingress_example.yaml

sed -i 's/YOUR_SERVICE_HERE/your-real-service-name/' services/cert-manager/ingress_example.yaml

k apply -f services/cert-manager/ingress_example.yaml
```

The last step needs to be done for every service. In this deployment step the cert-manager will handle the communication to Let's Encrypt and add the certificate to your service ingress resource.

### Multiple Subdomains for a Single Domain
The nice thing about this approach is that it allows you to easily get around the issue of Let's Encrypt not allowing for wildcard certificates when using the [HTTP01 Challenge Type](https://letsencrypt.org/docs/challenge-types/#http-01-challenge). This allows you to essentially have unlimited number of subdomains routed to different services/applications just by creating a new Ingress resource for each one.

All you need to do is create a DNS A record that points to one or more of your node IP addresses, then create a CNAME DNS record that maps the wildcard subdomain address (i.e. *.example.com) to the A record you just created. For example:

| Type  | Host name   | Data                                                   |
| ----- | ----------  | ------------------------------------------------------ |
| A     | example.com | 123.45.67.85, 123.45.67.86, 123.45.67.87, 123.45.67.89 |
| CNAME | *.example   | example.com.                                           | 

Once you have the DNS entries set up, you can then just create an ingress for each sub-domain that you want to use. You should use the same .spec.tls.secretName for each one. Each Ingress resource needs to be in the same namespace as the Service is is routing to.

## Upgrading K3s
As per the [K3s documentation](https://docs.k3s.io/upgrades/automated), [Rancher's system-upgrade-controller](https://github.com/rancher/system-upgrade-controller) can be used to automate the process of upgrading the K3s components.

To utilise this, first, install the system-upgrade-controller via Kubectl:

```bash
kubectl apply -f https://github.com/rancher/system-upgrade-controller/releases/latest/download/system-upgrade-controller.yaml
```

Next, prepare an upgrade plan based on the example at `services/k3s-upgrade-plan.yaml`. The key thing here is to set the `.spec.version` field to the version you want to upgrade to from [the K3s releases page](https://github.com/k3s-io/k3s/releases). Note that you should not jump up more than one minor version at a time.

Alternatively, for automatic updates to the latest stable version, replace `.spec.version` with `.spec.channel: https://github.com/k3s-io/k3s/releases` and K3s will always be upgraded when a new stable release is available.

Once you have prepared your plan and are ready to perform the upgrade, simply apply the YAML and monitor the upgrade until it completes.

```bash
kubectl apply -f services/k3s-upgrade-plan.yaml

# Watch all the nodes to see the upgrade happen in real time. Here, the first
# control plane node has been successfully upgraded to v1.26.3+k3s1 and the
# second control one is in progress before the server nodes.
watch kubectl get nodes -o wide
# NAME           STATUS                        ROLES                       AGE    VERSION        INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                        KERNEL-VERSION            CONTAINER-RUNTIME
# k3s-agent-0    Ready                         <none>                      101d   v1.25.5+k3s1   10.0.0.20     <none>        Fedora CoreOS 37.20230322.3.0   6.1.18-200.fc37.x86_64    containerd://1.6.12-k3s1
# k3s-agent-1    Ready                         <none>                      101d   v1.25.5+k3s1   10.0.0.21     <none>        Fedora CoreOS 37.20230322.3.0   6.1.18-200.fc37.x86_64    containerd://1.6.12-k3s1
# k3s-server-0   NotReady,SchedulingDisabled   control-plane,etcd,master   101d   v1.25.5+k3s1   10.0.0.10     <none>        Fedora CoreOS 37.20230322.3.0   6.1.18-200.fc37.aarch64   containerd://1.6.19-k3s1
# k3s-server-1   NotReady                      control-plane,etcd,master   101d   v1.26.3+k3s1   10.0.0.11     <none>        Fedora CoreOS 37.20230322.3.0   6.1.18-200.fc37.aarch64   containerd://1.6.19-k3s1

kubectl -n system-upgrade get plans -o yaml
kubectl -n system-upgrade get jobs -o yaml
```

If you specified a specific K3s version to upgrade to, then the next time you wish to upgrade, you simply need to update the `.spec.version` field in the two Plan definitions and then reapply the YAML file.

## TODOs
 * Automate the deployment of Fedora CoreOS and K3s
 * Terraform Load Balancer deployment
