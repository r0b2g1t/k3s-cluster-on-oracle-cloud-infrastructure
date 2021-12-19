terraform {
  required_providers {
    oci = {
      source = "hashicorp/oci"
    }
  }
}

provider "oci" {
  region              = "us-sanjose-1"
  auth                = "SecurityToken"
  config_file_profile = "terraform-deploy"
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
}

module "compute" {
  source     = "./compute"
  depends_on = ["network"]

  compartment_id    = var.compartment_id
  public_subnet_id  = module.network.cluster_subnet.id
  permit_ssh_nsg_id = module.network.permit_ssh.id
}
