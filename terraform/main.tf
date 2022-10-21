provider "oci" {
  region              = var.region
  tenancy_ocid        = var.tenancy_ocid
  user_ocid           = var.user_ocid
  fingerprint         = var.fingerprint
  private_key_path    = var.private_key_path
}

terraform {
  backend "s3" {
    bucket                      = "terraform-state"
    key                         = "k3s/terraform.tfstate"
    region                      = "eu-frankfurt-1"
    endpoint                    = "https://fr8ipbv8ozqv.compat.objectstorage.eu-frankfurt-1.oraclecloud.com"
    shared_credentials_file     = "shared_credentials_file"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
  }

  required_providers {
    oci = {
      source = "oracle/oci"
      version = ">= 4.0.0"
    }
  }
  required_version = ">= 1.0"
}



module "network" {
  source = "./network"

  compartment_id      = var.compartment_id
  tenancy_ocid        = var.tenancy_ocid
}

module "loadbalancer" {
  source              = "./loadbalancer"
  depends_on          = [module.network]
  compartment_id      = var.compartment_id
  tenancy_ocid        = var.tenancy_ocid
  cluster_subnet_id   = module.network.cluster_subnet.id
  permit_rules_nsg_id = module.network.permit_rules.id
}

module "compute" {
  source     = "./compute"
  depends_on = [module.loadbalancer]

  compartment_id      = var.compartment_id
  tenancy_ocid        = var.tenancy_ocid
  cluster_subnet_id   = module.network.cluster_subnet.id
  permit_rules_nsg_id = module.network.permit_rules.id
  ssh_authorized_keys = var.ssh_authorized_keys
  email_address       = var.email_address
  custom_domain       = var.custom_domain
  nlb_public_ip       = module.loadbalancer.nlb_public_ip
  nlb_private_ip      = module.loadbalancer.nlb_private_ip
}

module "fetch_config" {
  source              = "./fetch_config"
  depends_on          = [module.compute]
  server_1_public_ip  = module.compute.server_1_public_ip
  nlb_public_ip       = module.loadbalancer.nlb_public_ip
}