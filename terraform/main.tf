terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
  required_version = ">= 0.15"
}

provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}

module "network" {
  source = "./network"

  compartment_id = var.compartment_id
  tenancy_ocid   = var.tenancy_ocid
}

module "compute" {
  source     = "./compute"
  depends_on = [module.network]

  compartment_id          = var.compartment_id
  tenancy_ocid            = var.tenancy_ocid
  cluster_subnet_id       = module.network.cluster_subnet.id
  permit_http_nsg_id      = module.network.permit_http.id
  permit_kubectl_nsg_id   = module.network.permit_kubectl.id
  permit_ssh_nsg_id       = module.network.permit_ssh.id
  ssh_authorized_keys     = var.ssh_authorized_keys
}
