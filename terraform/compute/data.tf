data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = 2
}

resource "random_string" "cluster_token" {
  length  = 32
  special = true
  number  = true
  lower   = true
  upper   = true
}
