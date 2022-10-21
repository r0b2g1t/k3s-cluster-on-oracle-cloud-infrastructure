terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
      version = ">= 4.0.0"
    }
  }
  required_version = ">= 1.0"
}

provider "oci" {
  region              = var.region
  tenancy_ocid        = var.tenancy_ocid
  user_ocid           = var.user_ocid
  fingerprint         = var.fingerprint
  private_key_path    = var.private_key_path
}

module "bucket" {
  source = "./bucket"

  compartment_id      = var.compartment_id
  tenancy_ocid        = var.tenancy_ocid
  bucket              = var.bucket
}
