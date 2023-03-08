terraform {
  required_version = ">= 1.0.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 3.70.0"
      source  = "oracle/oci"
    }
  }
}

provider "oci" {
  private_key          = var.private_key
  private_key_password = var.private_key_password
}

module "network" {
  source = "./network"

  compartment_id = var.compartment_id
  tenancy_ocid   = var.tenancy_ocid

  cidr_blocks            = local.cidr_blocks
  ssh_managemnet_network = local.ssh_managemnet_network
}

module "compute" {
  source     = "./compute"
  depends_on = [module.network]

  compartment_id      = var.compartment_id
  tenancy_ocid        = var.tenancy_ocid
  cluster_subnet_id   = module.network.cluster_subnet.id
  permit_ssh_nsg_id   = module.network.permit_ssh.id
  ssh_authorized_keys = var.ssh_authorized_keys

  cidr_blocks = local.cidr_blocks
}
