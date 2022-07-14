resource "null_resource" "get_kubeconfig" {

  provisioner "local-exec" {
    command = "scp  -o 'StrictHostKeyChecking=no' ubuntu@${var.server_1_public_ip}:/etc/rancher/k3s/k3s.yaml k3s.yaml"
  }
}

resource "null_resource" "replace" {
  depends_on = [null_resource.get_kubeconfig]

  provisioner "local-exec" {
    command = "sed 's/127.0.0.1/api.${var.nlb_public_ip}.nip.io/g' k3s.yaml > k3s_fixed.yaml"
  }
}